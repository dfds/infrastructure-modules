package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"testing"

	appsv1 "k8s.io/api/apps/v1"
	apiv1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	intstr "k8s.io/apimachinery/pkg/util/intstr"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"

	"github.com/stretchr/testify/assert"

	traefikv1alpha1 "github.com/traefik/traefik/v3/pkg/provider/kubernetes/crd/traefikio/v1alpha1"

	"github.com/traefik/traefik/v3/pkg/config/dynamic"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/scheme"
)

func GetTraefikNamespace(clientset *kubernetes.Clientset) *string {
    ctx := context.TODO()

    // Get all namespaces
    namespaces, err := clientset.CoreV1().Namespaces().List(ctx, metav1.ListOptions{})
    if err != nil {
        log.Printf("Error listing namespaces: %v", err)
        return nil
    }

    // Check for Traefik namespace variants
    traefikVariants := []string{"traefik-blue-variant", "traefik-green-variant"}

    for _, ns := range namespaces.Items {
        for _, variant := range traefikVariants {
            if ns.Name == variant {
                return &variant
            }
        }
    }

    return nil
}

func TestTraefikDeployment(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertFluxReconciliation(t, clientset)
	traefikNamespace := GetTraefikNamespace(clientset)
    if traefikNamespace == nil {
        t.Fatal("Traefik namespace not found")
    }

    AssertK8sDeployment(t, clientset, *traefikNamespace, *traefikNamespace, 3)
}

func DeployTestcase(t *testing.T, clientset *kubernetes.Clientset) (*appsv1.Deployment, *apiv1.Service) {
	deploymentsClient := clientset.AppsV1().Deployments(apiv1.NamespaceDefault)

	deployment := &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{
			Name:      "nginx-test",
			Namespace: "default",
			Labels: map[string]string{
				"app": "nginx-test",
			},
		},
		Spec: appsv1.DeploymentSpec{
			Strategy: appsv1.DeploymentStrategy{
				Type: appsv1.RecreateDeploymentStrategyType,
			},
			Replicas: func() *int32 { i := int32(1); return &i }(),
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
							Name:  "nginx",
							Image: "nginx",
							LivenessProbe: &apiv1.Probe{
								ProbeHandler: apiv1.ProbeHandler{
									HTTPGet: &apiv1.HTTPGetAction{
										Port: intstr.IntOrString{IntVal: 80},
										Path: "/",
									},
								},
								InitialDelaySeconds: 3,
								PeriodSeconds:       3,
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
		t.Log(err)
	}
	fmt.Printf("Created deployment %q.\n", result.GetObjectMeta().GetName())

	serviceClient := clientset.CoreV1().Services(apiv1.NamespaceDefault)

	service := &apiv1.Service{
		ObjectMeta: metav1.ObjectMeta{
			Name:      "nginx-test",
			Namespace: "default",
		},
		Spec: apiv1.ServiceSpec{
			Ports: []apiv1.ServicePort{{
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
		t.Log(err)
	}
	fmt.Printf("Created service %q.\n", serviceResult.GetObjectMeta().GetName())

	return deployment, service
}

func CleanupTestcase(t *testing.T, clientset *kubernetes.Clientset, deployment *appsv1.Deployment, service *apiv1.Service) {
	deploymentsClient := clientset.AppsV1().Deployments(apiv1.NamespaceDefault)
	serviceClient := clientset.CoreV1().Services(apiv1.NamespaceDefault)

	deletePolicy := metav1.DeletePropagationForeground
	if err := deploymentsClient.Delete(context.TODO(), deployment.Name, metav1.DeleteOptions{
		PropagationPolicy: &deletePolicy,
	}); err != nil {
		t.Logf("error deleting Deployment: %v", err)
	}

	if err := serviceClient.Delete(context.TODO(), service.Name, metav1.DeleteOptions{}); err != nil {
		t.Logf("error deleting Service: %v", err)
	}
}

func TestTraefikIngressRouteAndMiddleware(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertFluxReconciliation(t, clientset)

	// Deploy nginx test resources
	deployment, service := DeployTestcase(t, clientset)

	// Custom Resources

	kubeconfig := filepath.Join(homedir.HomeDir(), ".kube", "qa.config")
	cfg, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		t.Logf("Error building kubeconfig: %v", err)
	}

	// Create a new scheme
	schemeBuilder := &scheme.Builder{GroupVersion: traefikv1alpha1.SchemeGroupVersion}
	schemeBuilder.Register(&traefikv1alpha1.Middleware{}, &traefikv1alpha1.MiddlewareList{})
	schemeBuilder.Register(&traefikv1alpha1.IngressRoute{}, &traefikv1alpha1.IngressRouteList{})

	clientScheme, err := schemeBuilder.Build()
	if err != nil {
		log.Fatalf("Error building scheme: %v", err)
	}

	// Create the controller-runtime client for Traefik CRDs
	k8sClient, err := client.New(cfg, client.Options{Scheme: clientScheme})
	if err != nil {
		t.Logf("Error creating controller-runtime client: %v", err)
	}

	// Traefik Middleware

	middleware := &traefikv1alpha1.Middleware{
		ObjectMeta: metav1.ObjectMeta{
			Name:      "middleware-test",
			Namespace: "default",
		},
		Spec: traefikv1alpha1.MiddlewareSpec{
			StripPrefix: &dynamic.StripPrefix{
				Prefixes: []string{"/test"},
			},
		},
	}

	if err := k8sClient.Create(context.TODO(), middleware); err != nil {
		t.Logf("error creating Middleware: %v", err)
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
							LoadBalancerSpec: traefikv1alpha1.LoadBalancerSpec{
								Name: "nginx-test",
								Port: intstr.IntOrString{
									Type:   intstr.Int,
									IntVal: 80,
								},
							},
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
		t.Logf("error creating IngressRoute: %v", err)
	}

	AssertK8sDeployment(t, clientset, "default", "nginx-test", 1)

	// Call the test endpoint
	resp, err := http.Get("https://nginx-test.qa.qa.dfds.cloud/test")
	if err != nil {
		t.Log(err)
	}
	defer resp.Body.Close()
	assert.Equal(t, 200, resp.StatusCode)

	// Delete resources

	if err := k8sClient.Delete(context.TODO(), middleware); err != nil {
		t.Logf("error deleting Middleware: %v", err)
	}

	if err := k8sClient.Delete(context.TODO(), ingressRoute); err != nil {
		t.Logf("error deleting IngressRoute: %v", err)
	}

	// Clean up nginx resources
	CleanupTestcase(t, clientset, deployment, service)
}
