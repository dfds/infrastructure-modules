package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"strings"
	"testing"

	appsv1 "k8s.io/api/apps/v1"
	apiv1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	intstr "k8s.io/apimachinery/pkg/util/intstr"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/kubernetes"

	"github.com/stretchr/testify/assert"
)

func TestTraefikDeployment(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertFluxReconciliation(t, clientset)
	AssertK8sDeployment(t, clientset, "traefik-blue-variant", "traefik-blue-variant", 3)
}

func TestTraefikIngressRouteAndMiddleware(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertFluxReconciliation(t, clientset)
	AssertK8sDeployment(t, clientset, "traefik-blue-variant", "traefik-blue-variant", 3)

	deploymentsClient := clientset.AppsV1().Deployments(apiv1.NamespaceDefault)
	dynamicClient, err := dynamic.NewForConfig(clientset.RESTConfig())

	deployment := &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{
			Name:      "nginx-test",
			Namespace: "default",
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: func() *int32 { i := int32(2); return &i }(),
			Selector: &metav1.LabelSelector{
				MatchLabels: map[string]string{
					"app": "nginx-test",
				},
			},
			Template: apiv1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: map[string]string{
						"app": "nginx-test",
					},
				},
				Spec: apiv1.PodSpec{
					Containers: []apiv1.Container{
						{
							Name:  "web",
							Image: "nginx",
							Ports: []apiv1.ContainerPort{
								{
									Name:          "http",
									Protocol:      apiv1.ProtocolTCP,
									ContainerPort: 80,
								},
							},
						},
					},
				},
			},
		},
	}

	// Create Deployment
	fmt.Println("Creating deployment...")
	result, err := deploymentsClient.Create(context.TODO(), deployment, metav1.CreateOptions{})
	if err != nil {
		panic(err)
	}
	fmt.Printf("Created deployment %q.\n", result.GetObjectMeta().GetName())

	serviceClient := clientset.CoreV1().Services(apiv1.NamespaceDefault)

	var service = &apiv1.Service{
		ObjectMeta: metav1.ObjectMeta{
			Name:      "nginx-test",
			Namespace: "default",
		},
		Spec: apiv1.ServiceSpec{
			Ports: []apiv1.ServicePort{apiv1.ServicePort{
				Name:       "web",
				Port:       int32(80),
				TargetPort: intstr.IntOrString{IntVal: int32(80)},
			}},
			Selector: map[string]string{"app": "nginx-test"},
		},
		TypeMeta: metav1.TypeMeta{
			APIVersion: "v1",
			Kind:       "Service",
		},
	}

	// Create Service
	fmt.Println("Creating service...")
	serviceResult, err := serviceClient.Create(context.TODO(), service, metav1.CreateOptions{})
	if err != nil {
		panic(err)
	}
	fmt.Printf("Created service %q.\n", serviceResult.GetObjectMeta().GetName())

	// Custom Resources

	kubeconfig := filepath.Join(homedir.HomeDir(), ".kube", "config")
	cfg, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		log.Fatalf("Error building kubeconfig: %v", err)
	}

	// Create the Kubernetes clientset

	customClientset, err := kubernetes.NewForConfig(cfg)
	if err != nil {
		log.Fatalf("Error creating Kubernetes clientset: %v", err)
	}

	_, err := customClientSet.Resource(ingressRouteGVR).Namespace("default").Create(context.TODO(), ingressRoute, metav1.CreateOptions{})
	if err != nil {
		return fmt.Errorf("error creating IngressRoute: %v", err)
	}

	// Create the controller-runtime client for Traefik CRDs
	k8sClient, err := client.New(cfg, client.Options{})
	if err != nil {
		log.Fatalf("Error creating controller-runtime client: %v", err)
	}

	// Traefik Middleware

	middleware := &traefikv1alpha1.Middleware{
		ObjectMeta: metav1.ObjectMeta{
			Name:      "middleware-test",
			Namespace: "default",
		},
		Spec: traefikv1alpha1.MiddlewareSpec{
			StripPrefix: &traefikv1alpha1.StripPrefix{
				Prefixes: []string{"/test"},
			},
		},
	}

	if err := k8sClient.Create(context.TODO(), middleware); err != nil {
		return fmt.Errorf("error creating Middleware: %v", err)
	}

	// Traefik IngressRoute

	ingressRoute := &traefikv1alpha1.IngressRoute{
		ObjectMeta: metav1.ObjectMeta{
			Name:      "nginx-test",
			Namespace: "default",
		},
		Spec: traefikv1alpha1.IngressRouteSpec{
			Routes: []traefikv1alpha1.Route{
				{
					Match: "Host(`nginx-test.qa.qa.dfds.cloud`) && PathPrefix(`/test`)",
					Kind:  "Rule",
					Services: []traefikv1alpha1.Service{
						{
							Name: "nginx-test",
							Port: 80,
						},
					},
					Middlewares: []traefikv1alpha1.MiddlewareRef{
						{
							Name: "middleware-test",
						},
					},
				},
			},
		},
	}

	if err := k8sClient.Create(context.TODO(), ingressRoute); err != nil {
		return fmt.Errorf("error creating IngressRoute: %v", err)
	}

	// Delete resources

	if err := k8sClient.Delete(context.TODO(), middleware); err != nil {
		return fmt.Errorf("error deleting Middleware: %v", err)
	}

	if err := k8sClient.Delete(context.TODO(), ingressRoute); err != nil {
		return fmt.Errorf("error deleting IngressRoute: %v", err)
	}

	deletePolicy := metav1.DeletePropagationForeground
	if err := deploymentsClient.Delete(context.TODO(), name, metav1.DeleteOptions{
		PropagationPolicy: &deletePolicy,
	}); err != nil {
		return fmt.Errorf("error deleting Deployment: %v", err)
	}

	servicesClient := clientset.CoreV1().Services(namespace)
	if err := servicesClient.Delete(context.TODO(), name, metav1.DeleteOptions{}); err != nil {
		return fmt.Errorf("error deleting Service: %v", err)
	}

	// The Grafana deployment utilizes the Traefik resources IngressRoute and
	// Middleware to expose a public endpoint. This public endpoint will be
	// used to check if Traefik is routing traffic correctly.
	AssertK8sDeployment(t, clientset, "default", "test-ingress-deployment", 1)

	// Call the Grafana health endpoint and parse the response
	resp, err := http.Get("https://nginx-test.qa.qa.dfds.cloud/test")
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	assert.Equal(t, 200, resp.StatusCode)
	msg := struct {
		Commit   string `json:"commit"`
		Database string `json:"database"`
		Version  string `json:"version"`
	}{}
	decoder := json.NewDecoder(resp.Body)
	err = decoder.Decode(&msg)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, "ok", strings.ToLower(msg.Database))
}
