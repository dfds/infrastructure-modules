package main

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

func NewK8sClientSet(t *testing.T) *kubernetes.Clientset {
	kubeConfig := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
		clientcmd.NewDefaultClientConfigLoadingRules(), &clientcmd.ConfigOverrides{})
	config, err := kubeConfig.ClientConfig()
	if err != nil {
		t.Fatal(err.Error())
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		t.Fatal(err.Error())
	}
	return clientset
}

const (
	defaultEventualTimeout time.Duration = 5 * time.Minute
	defaultEventualPeriod  time.Duration = 5 * time.Second
)

func AssertDaemonSet(t *testing.T, clientset *kubernetes.Clientset, namespace, name string, numberAvailable int) {
	check := func() bool {
		resp, err := clientset.AppsV1().DaemonSets(namespace).Get(
			context.Background(), name, metav1.GetOptions{})
		if err != nil {
			t.Log(err.Error())
			return false
		}

		// Assertions
		if int(resp.Status.NumberAvailable) != numberAvailable {
			t.Logf("expecting number available pods to be %d, found %d",
				numberAvailable, resp.Status.NumberAvailable)
			return false
		}
		return true
	}

	assert.Eventuallyf(t, check, defaultEventualTimeout, defaultEventualPeriod,
		"daemonset %q in namespace %q and %d available pods not found",
		name, namespace, numberAvailable)
}

func AssertDeployment(t *testing.T, clientset *kubernetes.Clientset, namespace, name string, numberAvailable int) {
	check := func() bool {
		resp, err := clientset.AppsV1().Deployments(namespace).Get(
			context.Background(), name, metav1.GetOptions{})
		if err != nil {
			t.Log(err.Error())
			return false
		}

		// Assertions
		if int(resp.Status.AvailableReplicas) != numberAvailable {
			t.Logf("expecting number of available replicas to be %d, found %d",
				numberAvailable, resp.Status.AvailableReplicas)
			return false
		}
		return true
	}

	assert.Eventuallyf(t, check, defaultEventualTimeout, defaultEventualPeriod,
		"deployment %q in namespace %q and %d available replicas not found",
		name, namespace, numberAvailable)
}

func AssertStatefulSet(t *testing.T, clientset *kubernetes.Clientset, namespace, name string, numberAvailable int) {
	check := func() bool {
		resp, err := clientset.AppsV1().StatefulSets(namespace).Get(
			context.Background(), name, metav1.GetOptions{})
		if err != nil {
			t.Log(err.Error())
			return false
		}

		// Assertions
		if int(resp.Status.AvailableReplicas) != numberAvailable {
			t.Logf("expecting number of available replicas to be %d, found %d",
				numberAvailable, resp.Status.AvailableReplicas)
			return false
		}
		return true
	}

	assert.Eventuallyf(t, check, defaultEventualTimeout, defaultEventualPeriod,
		"stateful set %q in namespace %q and %d available replicas not found",
		name, namespace, numberAvailable)
}
