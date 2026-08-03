package main

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
)

func TestVpcCniDriverDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDaemonSet(t, clientset, "kube-system", "aws-node")
}

func TestVpcCniPrefixDelegationEnabled(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "kube-system")
	ds := k8s.GetDaemonSet(t, options, "aws-node")

	prefixDeletegationEnabled := false
	for _, env := range ds.Spec.Template.Spec.Containers[0].Env {
		if env.Name == "ENABLE_PREFIX_DELEGATION" {
			assert.Equal(t, "true", env.Value, "Expected ENABLE_PREFIX_DELEGATION to be set to 'true'")
			prefixDeletegationEnabled = true
		}
	}
	assert.True(t, prefixDeletegationEnabled, "ENABLE_PREFIX_DELEGATION environment variable not found")
}
