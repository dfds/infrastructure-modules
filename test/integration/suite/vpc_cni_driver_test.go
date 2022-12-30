package main

import "testing"

func TestVpcCniDriverDaemonSet(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertDaemonSet(t, clientset, "kube-system", "aws-node", 3)
}
