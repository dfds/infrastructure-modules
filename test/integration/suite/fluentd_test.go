package main

import "testing"

func TestFluentdDaemonSet(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertDaemonSet(t, clientset, "fluentd", "fluentd-cloudwatch", 3)
}
