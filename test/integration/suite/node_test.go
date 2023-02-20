package main

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestNodeMaxPod(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)

	resp, err := clientset.CoreV1().Nodes().List(context.Background(), metav1.ListOptions{})
	if err != nil {
		t.Log(err.Error())
		return
	}

	for _, node := range resp.Items {
		assert.EqualValues(t, node.Status.Capacity.Pods().Value(),
			// Asssuming a m5a.xlarge instance and prefix delegation enabled the
			// limit should be 898, if disabled it should be 58.
			898, "node %q pods limit does not match", node.Name)
	}
}
