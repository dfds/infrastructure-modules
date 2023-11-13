package main

import "testing"

func TestKubeProxyDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDaemonSet(t, clientset, "kube-system", "kube-proxy", 5)
}
