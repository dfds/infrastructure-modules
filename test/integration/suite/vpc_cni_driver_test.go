package main

import "testing"

func TestVpcCniDriverDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertDaemonSet(t, clientset, "kube-system", "aws-node", 3)
}
