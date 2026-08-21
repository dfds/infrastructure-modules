package main

import (
	"crypto/tls"
	"testing"

	"github.com/gruntwork-io/terratest/modules/httphelper/v2"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
)

// TestAnonymousAuthApiServer tests that the API server is configured to allow anonymous access to /healthz and deny access to /apis.
func TestAnonymousAuthApiServer(t *testing.T) {
	t.Parallel()
	client := k8s.GetKubernetesClientContext(t, t.Context())
	endpoint := client.RESTClient().Get().URL().String()
	tlsConfig := tls.Config{InsecureSkipVerify: true}

	// Test that /healthz endpoint is accessible for anonymous access
	statusCode, _ := httphelper.HTTPGetContext(t, t.Context(), endpoint+"healthz", &tlsConfig)
	assert.Equal(t, 200, statusCode, "Expected status code 200 on /healthz, got %d", statusCode)

	// Test that /version endpoint is secured and returns 401 for anonymous access
	statusCode, _ = httphelper.HTTPGetContext(t, t.Context(), endpoint+"apis", &tlsConfig)
	assert.Equal(t, 401, statusCode, "Expected status code 401 on /apis, got %d", statusCode)

	// Test that /version is also secured and returns 401 for anonymous access
	statusCode, _ = httphelper.HTTPGetContext(t, t.Context(), endpoint+"version", &tlsConfig)
	assert.Equal(t, 401, statusCode, "Expected status code 401 on /version, got %d", statusCode)
}
