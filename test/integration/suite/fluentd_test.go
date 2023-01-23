package main

import "testing"

func TestFluentdDaemonSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDaemonSet(t, clientset, "fluentd", "fluentd-cloudwatch", 3)
}
