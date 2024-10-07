package main

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestGeneralNodeMaxPod(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)

	resp, err := clientset.CoreV1().Nodes().List(context.Background(),
		metav1.ListOptions{
			LabelSelector: "eks.amazonaws.com/nodegroup in (general)",
		})
	if err != nil {
		t.Log(err.Error())
		return
	}

	for _, node := range resp.Items {
		assert.EqualValues(t,
			// Asssuming a m5a.xlarge instance and prefix delegation enabled the
			// limit should be 110, if disabled it should be 58.
			110, node.Status.Capacity.Pods().Value(), "general node group %q pods limit does not match", node.Name)
	}
}

func TestObservabilityNodeMaxPod(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)

	resp, err := clientset.CoreV1().Nodes().List(context.Background(),
		metav1.ListOptions{
			LabelSelector: "eks.amazonaws.com/nodegroup in (observability)",
		})
	if err != nil {
		t.Log(err.Error())
		return
	}

	for _, node := range resp.Items {
		assert.EqualValues(t,
			// This node group has an overriden value for max pods to avoid
			// excessive memory reservations by the kubelet to accomodate a
			// higher limit for pods.
			30, node.Status.Capacity.Pods().Value(), "observability node %q pods limit does not match", node.Name)
	}
}

func TestObservabilityNodeTaints(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)

	resp, err := clientset.CoreV1().Nodes().List(context.Background(),
		metav1.ListOptions{
			LabelSelector: "eks.amazonaws.com/nodegroup in (observability)",
		})
	if err != nil {
		t.Log(err.Error())
		return
	}

	for _, node := range resp.Items {
		assert.Equal(t, 1, len(node.Spec.Taints))
		taint := node.Spec.Taints[0]
		assert.Equal(t, "observability.dfds", taint.Key)
		assert.Equal(t, v1.TaintEffectNoSchedule, taint.Effect)
		assert.Equal(t, "", taint.Value)
	}
}

func TestObservabilityNodeLabels(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)

	resp, err := clientset.CoreV1().Nodes().List(context.Background(),
		metav1.ListOptions{
			LabelSelector: "eks.amazonaws.com/nodegroup in (observability)",
		})
	if err != nil {
		t.Log(err.Error())
		return
	}

	for _, node := range resp.Items {
		assert.Equal(t, "observability", node.Labels["dedicated"])
	}
}
