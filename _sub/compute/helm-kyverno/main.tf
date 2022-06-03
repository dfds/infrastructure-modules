resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "kyverno"
  }
}

resource "helm_release" "kyverno" {
  name          = "kyverno"
  chart         = "kyverno"
  repository    = "https://kyverno.github.io/kyverno/"
  version       = var.chart_version
  namespace     = kubernetes_namespace.namespace.metadata[0].name
  recreate_pods = true
  force_update  = false
}

resource "kubernetes_config_map" "configmap" {
  metadata {
    name = "service-namespace-filters"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    exclude = jsonencode(var.excluded_namespaces)
  }
}

resource "kubectl_manifest" "cluster_policy_nodeport" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-nodeport
  annotations:
    policies.kyverno.io/title: Disallow NodePort
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/description: >-
      A Kubernetes Service of type NodePort uses a host port to receive traffic from
      any source. A NetworkPolicy cannot be used to control traffic to host ports.
      Although NodePort Services can be useful, their use must be limited to Services
      with additional upstream security checks. This policy validates that any new Services
      do not use the `NodePort` type.      
spec:
  validationFailureAction: enforce
  background: true
  rules:
  - name: validate-nodeport
    context:
      - name: namespacefilters
        configMap:
          name: service-namespace-filters
          namespace: ${kubernetes_namespace.namespace.metadata[0].name}
    match:
      resources:
        kinds:
        - Service
    preconditions:
      any:
        - key: "{{request.object.metadata.namespace}}"
          operator: AnyNotIn
          value: "{{namespacefilters.data.exclude}}"
    validate:
      message: "Services of type NodePort are not allowed."
      pattern:
        spec:
          type: "!NodePort"
YAML

  depends_on = [helm_release.kyverno, kubernetes_config_map.configmap]
}

resource "kubectl_manifest" "cluster_policy_loadbalancer" {
    yaml_body = <<YAML
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-loadbalancer
  annotations:
    policies.kyverno.io/title: Disallow LoadBalancer
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/description: >-
      A Kubernetes Service of type LoadBalancer uses a host port to receive traffic from
      any source. A NetworkPolicy cannot be used to control traffic to host ports.
      Although LoadBalancer Services can be useful, their use must be limited to Services
      with additional upstream security checks. This policy validates that any new Services
      do not use the `LoadBalancer` type.      
spec:
  validationFailureAction: enforce
  background: true
  rules:
  - name: validate-loadbalancer
    context:
      - name: namespacefilters
        configMap:
          name: service-namespace-filters
          namespace: ${kubernetes_namespace.namespace.metadata[0].name}
    match:
      resources:
        kinds:
        - Service
    preconditions:
      any:
        - key: "{{request.object.metadata.namespace}}"
          operator: AnyNotIn
          value: "{{namespacefilters.data.exclude}}"
    validate:
      message: "Services of type LoadBalancer are not allowed."
      pattern:
        spec:
          type: "!LoadBalancer"
YAML
  depends_on = [helm_release.kyverno, kubernetes_config_map.configmap]
}