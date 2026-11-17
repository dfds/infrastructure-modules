package main

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

func TestExternalDNSDeployment(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "external-dns")
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "external-dns", 60, 5*time.Second)
}
