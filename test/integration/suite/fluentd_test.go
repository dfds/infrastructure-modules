package main

import "testing"

func TestFluentdDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertDaemonSet(t, clientset, "fluentd", "fluentd-cloudwatch", 3)
}
