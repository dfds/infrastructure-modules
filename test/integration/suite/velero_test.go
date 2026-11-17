package main

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

func TestVeleroNodeAgentDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDaemonSet(t, clientset, "velero", "node-agent")
}

func TestVeleroDeployment(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "velero")
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "velero", 60, 5*time.Second)
}
