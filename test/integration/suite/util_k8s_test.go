package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	corev1 "k8s.io/api/core/v1"
	eventsv1 "k8s.io/api/events/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
)

var kubeClientConfig *rest.Config

func initK8s() {
	kubeConfig := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
		clientcmd.NewDefaultClientConfigLoadingRules(), &clientcmd.ConfigOverrides{})
	var err error
	kubeClientConfig, err = kubeConfig.ClientConfig()
	if err != nil {
		log.Fatal(err.Error())
	}
	log.Println("Kube client config initialized")
}

func NewK8sClientSet(t *testing.T) *kubernetes.Clientset {
	clientset, err := kubernetes.NewForConfig(kubeClientConfig)
	if err != nil {
		t.Fatal(err.Error())
	}
	return clientset
}

const (
	defaultEventualTimeout time.Duration = 5 * time.Minute
	defaultEventualPeriod  time.Duration = 5 * time.Second
)

func SetK8sAnnotation(gvr schema.GroupVersionResource, namespace, name, key, value string) error {
	client, err := dynamic.NewForConfig(kubeClientConfig)
	if err != nil {
		return err
	}

	// Get the resource
	obj, err := client.Resource(gvr).
		Namespace(namespace).
		Get(context.Background(), name, metav1.GetOptions{})
	if err != nil {
		return err
	}

	// Formulate the patch
	patch := map[string]interface{}{
		"metadata": map[string]interface{}{
			"annotations": map[string]string{
				key: value,
			},
		},
	}
	patchBytes, err := json.Marshal(patch)
	if err != nil {
		return err
	}

	// Apply the patch
	_, err = client.Resource(gvr).
		Namespace(obj.GetNamespace()).
		Patch(context.Background(), obj.GetName(), types.MergePatchType, patchBytes, metav1.PatchOptions{})
	if err != nil {
		return err
	}
	return nil
}

func AssertK8sDaemonSet(t *testing.T, clientset *kubernetes.Clientset, namespace, name string, numberAvailable int) {
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

func AssertK8sDeployment(t *testing.T, clientset *kubernetes.Clientset, namespace, name string, numberAvailable int) {
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

func AssertK8sStatefulSet(t *testing.T, clientset *kubernetes.Clientset, namespace, name string, numberAvailable int) {
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

func AssertK8sEvent(t *testing.T, clientset *kubernetes.Clientset, namespace,
	eventType, eventReason string, regarding corev1.ObjectReference, emittedAfter time.Time) {
	check := func() bool {
		var err error
		var resp *eventsv1.EventList
		var continueToken string
		for {
			if resp != nil {
				if resp.ListMeta.Continue == "" {
					break
				}
				continueToken = resp.ListMeta.Continue
			}
			resp, err = clientset.EventsV1().Events(namespace).List(
				context.Background(), metav1.ListOptions{
					FieldSelector: fmt.Sprintf("reason=%s,type=%s", eventReason, eventType),
					Continue:      continueToken,
				})
			if err != nil {
				t.Log(err.Error())
				return false
			}

			for _, event := range resp.Items {
				if event.Regarding.Kind != regarding.Kind ||
					event.Regarding.Name != regarding.Name {
					continue
				}
				// Consecutive similar events could be combined into one event so one must
				// check the last observed time.
				if event.DeprecatedLastTimestamp.Time.Before(emittedAfter) {
					continue
				}
				return true
			}
		}

		return false
	}

	assert.Eventuallyf(t, check, defaultEventualTimeout, defaultEventualPeriod,
		"event with type %q and reason %q in namespace %q not found after %s",
		eventType, eventReason, namespace, emittedAfter)
}
