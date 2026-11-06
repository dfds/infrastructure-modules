package main

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

func TestCertManagerDeployment(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "cert-manager")
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "cert-manager", 60, 5*time.Second)
}

func TestCertManagerCAInjectorDeployment(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "cert-manager")
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "cert-manager-cainjector", 60, 5*time.Second)
}

func TestCertManagerWebhookDeployment(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "cert-manager")
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "cert-manager-webhook", 60, 5*time.Second)
}
