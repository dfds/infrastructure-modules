package main

import "testing"

func TestVpcCniDriverDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDaemonSet(t, clientset, "kube-system", "aws-node", 3)
}
