data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  helm_repo_path      = "platform-apps/${var.cluster_name}/${var.deploy_name}/helm"
  app_install_name    = "platform-apps-${var.deploy_name}"
}

locals {
  app_helm_path = <<YAML
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: "${local.app_install_name}-helm"
  namespace: "flux-system"
spec:
  interval: 1m0s
  dependsOn:
    - name: "platform-apps-sources"
    - name: ${var.controller_deploy_name}

  sourceRef:
    kind: GitRepository
    name: "flux-system"
  path: "./${local.helm_repo_path}"
  prune: ${var.prune}
YAML

  helm_install = <<YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - "${var.gitops_apps_repo_url}/apps/github-arc-runners?ref=${var.gitops_apps_repo_branch}"
  - "serviceaccount.yaml"
  - "role.yaml"
  - "rolebinding.yaml"
patchesStrategicMerge:
  - "patch.yaml"
YAML

  helm_patch = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: ${var.deploy_name}
  namespace: ${var.namespace}
spec:
  chart:
    spec:
      version: ${var.helm_chart_version}
  values:
    githubConfigUrl: ${var.github_config_url}
    githubConfigSecret: ${var.github_config_secret}
    runnerScaleSetName: ${var.runner_scale_set_name}
    minRunners: ${var.min_runners}
    maxRunners: ${var.max_runners}
    template:
      spec:
        serviceAccountName: ${var.deploy_name}-sa
        securityContext:
          fsGroup: 123
        containers:
        - name: runner
          image: ghcr.io/actions/actions-runner:latest
          command: ["/home/runner/run.sh"]
          resources:
            requests:
              memory: "${var.runner_memory_request}"
            limits:
              memory: "${var.runner_memory_limit}"
          env:
            - name: ACTIONS_RUNNER_CONTAINER_HOOKS
              value: /home/runner/k8s/index.js
            - name: ACTIONS_RUNNER_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER
              value: "false"
          volumeMounts:
            - name: work
              mountPath: /home/runner/_work
        volumes:
          - name: work
            ephemeral:
              volumeClaimTemplate:
                spec:
                  accessModes: [ "ReadWriteOnce" ]
                  storageClassName: ${var.storage_class_name}
                  resources:
                    requests:
                      storage: ${var.storage_request_size}
    metrics:
      controllerManagerAddr: ":8080"
      listenerAddr: ":8080"
      listenerEndpoint: "/metrics"
YAML

  serviceaccount = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${var.deploy_name}-sa
  namespace: ${var.namespace}
YAML

  role = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${var.deploy_name}-role
  namespace: ${var.namespace}
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "create", "delete"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["get", "create"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch"]
  resources: ["jobs"]
  verbs: ["get", "list", "create", "delete"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["create", "delete", "get", "list"]
YAML

  rolebinding = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${var.deploy_name}-rolebinding
  namespace: ${var.namespace}
subjects:
- kind: ServiceAccount
  name: ${var.deploy_name}-sa
  namespace: ${var.namespace}
roleRef:
  kind: Role
  name: ${var.deploy_name}-role
  apiGroup: rbac.authorization.k8s.io
YAML

}
