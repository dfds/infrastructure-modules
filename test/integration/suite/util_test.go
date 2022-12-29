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

// TODO(emil): assertion that a resource with given label exists (eventually) with the specified status

const (
	defaultEventualTimeout time.Duration = 5 * time.Minute
	defaultEventualPeriod  time.Duration = 5 * time.Second
)

func AssertDaemonSet(t *testing.T, clientset *kubernetes.Clientset, namespace, name string, numberAvailable int) {
	check := func() bool {
		resp, err := clientset.AppsV1().DaemonSets(namespace).List(
			context.Background(), metav1.ListOptions{
				LabelSelector: "app.kubernetes.io/name=" + name,
			})
		if err != nil {
			t.Log(err.Error())
			return false
		}
		if len(resp.Items) != 1 {
			t.Logf("expecting one resource to match the label, found %d\n", len(resp.Items))
			return false
		}

		// Assertions on the daemonset state
		ds := resp.Items[0]
		if int(ds.Status.NumberAvailable) != numberAvailable {
			t.Logf("expecting number available to be %d, found %d",
				numberAvailable, ds.Status.NumberAvailable)
			return false
		}
		return true
	}
	assert.Eventuallyf(t, check, defaultEventualTimeout, defaultEventualPeriod,
		"daemonset %q in namespace %q and %d available pods not found",
		name, namespace, numberAvailable)
}
