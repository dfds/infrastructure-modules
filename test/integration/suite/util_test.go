package main

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	corev1 "k8s.io/api/core/v1"
	eventsv1 "k8s.io/api/events/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

// testSuiteStartTime is used to keep track of when the test binary began executing
// some assertions (i.e. events) want to limit their queries to resources which were
// created only after this time.
var testSuiteStartTime time.Time

func init() {
	testSuiteStartTime = time.Now()
}

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

func AssertEvent(t *testing.T, clientset *kubernetes.Clientset, namespace, eventType, eventReason string, regarding corev1.ObjectReference, emittedAfter time.Time) {
	check := func() bool {
		// TODO(emil): turn into a list request
		// TODO(emil): filter the events to the ones that match the criteria

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
			t.Log("request, continue token", continueToken)
			resp, err = clientset.EventsV1().Events(namespace).List(
				context.Background(), metav1.ListOptions{
					FieldSelector: fmt.Sprintf("reason=%s,type=%s", eventReason, eventType),
					Continue:      continueToken,
					Limit:         5,
				})
			if err != nil {
				t.Log(err.Error())
				return false
			}
			t.Log("resp, remaining/continue", resp.ListMeta.RemainingItemCount, resp.ListMeta.Continue)

			// TODO(emil): filter the event by the involved object
			for i, event := range resp.Items {
				if event.Regarding.Kind != regarding.Kind ||
					event.Regarding.Name != regarding.Name {
					t.Log("skip event, regarding", event.Regarding.Kind, event.Regarding.Name)
					continue
				}
				t.Log("i", i)
				t.Log("type", event.Type)
				t.Log("event time", event.EventTime)
				t.Log("reason", event.Reason)
				t.Log("regarding", event.Regarding.Kind, event.Regarding.Name)
				return true
			}
		}

		return false
	}

	assert.Eventuallyf(t, check, defaultEventualTimeout, defaultEventualPeriod,
		"event with type %q and reason %q in namespace %q not found after %s",
		eventType, eventReason, namespace, emittedAfter)
}
