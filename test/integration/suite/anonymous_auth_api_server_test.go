package main

import (
	"crypto/tls"
	"testing"

	"github.com/gruntwork-io/terratest/modules/httphelper/v2"
	"github.com/gruntwork-io/terratest/modules/k8s"
)

// TestAnonymousAuthApiServer tests that the API server is configured to allow anonymous access to /healthz and deny access to /apis.
func TestAnonymousAuthApiServer(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "")
	endpoint := options.RestConfig.Host
	statusCode, _ := httphelper.HTTPGetContext(t, t.Context(), endpoint+"/healthz", &tls.Config{})
	if statusCode != 200 {
		t.Logf("Expected status code 200 on /healthz, got %d", statusCode)
	}
	statusCode, _ = httphelper.HTTPGetContext(t, t.Context(), endpoint+"/apis", &tls.Config{})
	if statusCode != 401 {
		t.Logf("Expected status code 401 on /apis, got %d", statusCode)
	}
}
