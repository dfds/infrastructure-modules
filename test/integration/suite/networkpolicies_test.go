package main

import (
	_ "embed"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/assert"
)

//go:embed k8s/networkpolicies/pods.yaml
var networkPoliciesTestPod string

//go:embed k8s/networkpolicies/deny-all.yaml
var networkPoliciesDenyAll string

//go:embed k8s/networkpolicies/allow-ingress-egress.yaml
var networkPoliciesAllowIngress string

func TestNetworkPoliciesEnabled(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "kube-system")
	ds := k8s.GetDaemonSetContext(t, t.Context(), options, "aws-node")

	networkPolicyEnforcingModeFound := false
	for _, env := range ds.Spec.Template.Spec.Containers[0].Env {
		if env.Name == "NETWORK_POLICY_ENFORCING_MODE" {
			assert.Equal(t, "standard", env.Value, "Expected NETWORK_POLICY_ENFORCING_MODE to be set to 'standard'")
			networkPolicyEnforcingModeFound = true
		}
	}
	assert.True(t, networkPolicyEnforcingModeFound, "NETWORK_POLICY_ENFORCING_MODE environment variable not found")
	assert.Contains(t, ds.Spec.Template.Spec.Containers[1].Args, "--enable-network-policy=true", "NetworkPolicy should be enabled in aws-node daemonset")
}

func TestNetworkPolicies(t *testing.T) {
	t.Parallel()
	namespace := fmt.Sprintf("networkpolicy-test-%s", strings.ToLower(random.UniqueID()))
	options := k8s.NewKubectlOptions("", "", namespace)
	k8s.CreateNamespaceContext(t, t.Context(), options, namespace)

	defer k8s.DeleteNamespaceContext(t, t.Context(), options, namespace)
	defer k8s.KubectlDeleteFromStringContext(t, t.Context(), options, networkPoliciesTestPod)
	defer k8s.KubectlDeleteFromStringContext(t, t.Context(), options, networkPoliciesDenyAll)
	defer k8s.KubectlDeleteFromStringContext(t, t.Context(), options, networkPoliciesAllowIngress)

	// Check that there are no network policies in the namespace
	np, err := k8s.RunKubectlAndGetOutputContextE(t, t.Context(), options, "get", "networkpolicy", "-n", namespace)
	assert.NoError(t, err)
	assert.Contains(t, np, "No resources found")

	// Spawn test pods
	k8s.KubectlApplyFromStringContext(t, t.Context(), options, networkPoliciesTestPod)
	k8s.WaitUntilPodAvailableContext(t, t.Context(), options, "networkpolicies-test-pod", 60, 5*time.Second)
	k8s.WaitUntilPodAvailableContext(t, t.Context(), options, "networkpolicies-test-exec-pod", 60, 5*time.Second)

	// Check test pod with curl from exec pod, should work as there are no network policies
	k8s.ExecPodContext(t, t.Context(), options, "networkpolicies-test-exec-pod", "networkpolicies-test-exec-pod", "curl", "-sS", "--connect-timeout", "2", "http://networkpolicies-test-service:80")

	// Create a network policy that denies all traffic to the test pod
	k8s.KubectlApplyFromStringContext(t, t.Context(), options, networkPoliciesDenyAll)

	// Check test pod with curl from exec pod, should fail as there is a deny all network policy
	_, err = k8s.ExecPodContextE(t, t.Context(), options, "networkpolicies-test-exec-pod", "networkpolicies-test-exec-pod", "curl", "-sS", "--connect-timeout", "2", "http://networkpolicies-test-service:80")
	assert.Error(t, err, "Expected curl to fail due to deny all network policy")

	// Create a network policy that allows ingress traffic from the exec pod to the test pod
	k8s.KubectlApplyFromStringContext(t, t.Context(), options, networkPoliciesAllowIngress)

	// Check test pod with curl from exec pod, should work as there is an allow ingress network policy
	k8s.ExecPodContext(t, t.Context(), options, "networkpolicies-test-exec-pod", "networkpolicies-test-exec-pod", "curl", "-sS", "--connect-timeout", "2", "http://networkpolicies-test-service:80")
}
