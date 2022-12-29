package main

import "testing"

func TestEbsCsiDriveDaemonSet(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertDaemonSet(t, clientset, "kube-system", "ebs-csi-node", 3)
}
