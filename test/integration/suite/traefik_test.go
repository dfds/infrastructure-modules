package main

import (
	"encoding/json"
	"net/http"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestTraefikDeployment(t *testing.T) {
	clientset := NewK8sClientSet(t)
	// AssertFluxReconciliation(t, clientset)
	AssertK8sDeployment(t, clientset, "traefik-blue-variant", "traefik-blue-variant", 3)
}

// The Grafana endpoint is not public any longer, but protected by SSO.
func TestTraefikIngressRouteAndMiddleware(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertFluxReconciliation(t, clientset)
	AssertK8sDeployment(t, clientset, "traefik-blue-variant", "traefik-blue-variant", 3)

	// The Grafana deployment utilizes the Traefik resources IngressRoute and
	// Middleware to expose a public endpoint. This public endpoint will be
	// used to check if Traefik is routing traffic correctly.
	AssertK8sDeployment(t, clientset, "monitoring", "monitoring-grafana", 1)

	// Call the Grafana health endpoint and parse the response
	resp, err := http.Get("https://grafana.qa.qa.dfds.cloud/infrastructure/api/health")
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	assert.Equal(t, 200, resp.StatusCode)
	msg := struct {
		Commit   string `json:"commit"`
		Database string `json:"database"`
		Version  string `json:"version"`
	}{}
	decoder := json.NewDecoder(resp.Body)
	err = decoder.Decode(&msg)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, "ok", strings.ToLower(msg.Database))
}
