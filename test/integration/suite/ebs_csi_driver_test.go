package main

import "testing"

func TestEbsCsiDriverDeployment(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertDeployment(t, clientset, "kube-system", "ebs-csi-controller", 2)
}

func TestEbsCsiDriverDaemonSet(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertDaemonSet(t, clientset, "kube-system", "ebs-csi-node", 3)
}
