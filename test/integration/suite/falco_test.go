package main

import (
	"testing"
)

func TestFalcoDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDaemonSet(t, clientset, "falco", "falco-falco")
}
