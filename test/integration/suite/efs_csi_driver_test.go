package main

import "testing"

func TestEbsEfsDriverDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "kube-system", "efs-csi-controller", 2)
}

func TestEbsEfsDriverDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDaemonSet(t, clientset, "kube-system", "efs-csi-node", 4)
}
