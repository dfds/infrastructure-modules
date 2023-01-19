package main

import "testing"

func TestKubeProxyDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertDaemonSet(t, clientset, "kube-system", "kube-proxy", 3)
}
