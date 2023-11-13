package main

import "testing"

func TestEbsCsiDriverDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "kube-system", "ebs-csi-controller", 2)
}

func TestEbsCsiDriverDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDaemonSet(t, clientset, "kube-system", "ebs-csi-node", 5)
}
