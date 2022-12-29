package main

import (
	"context"
	"testing"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// TODO(emil): write a simple test to test that it connects to k8s

func TestPods(t *testing.T) {
	clientset := NewK8sClientSet(t)
	pods, err := clientset.CoreV1().Pods("kube-system").List(context.Background(), metav1.ListOptions{})
	if err != nil {
		t.Fatal(err.Error())
	}
	t.Logf("There are %d pods in the cluster\n", len(pods.Items))
}
