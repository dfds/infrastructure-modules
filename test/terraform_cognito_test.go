package test

import (
	"fmt"
	"testing"
	"io/ioutil"
	"path/filepath"
	//"strings"
	"os"

	"github.com/gruntwork-io/terratest/modules/files"
	//"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	// dfds "github.com/dfds/terratest/modules/aws"
	// "github.com/stretchr/testify/assert"
)

// An example of how to test the Terraform module in examples/terraform-aws-example using Terratest.
func TestTerraformAwsExample(t *testing.T) {
	t.Parallel()

	stateDirectory, err := ioutil.TempDir("", t.Name())
 	if err != nil {
 		t.Fatal(err)
	 }
	 remoteStateFile := filepath.Join(stateDirectory, "backend.tfstate")

	// Give this EC2 Instance a unique ID for a name tag so we can distinguish it from any other EC2 Instance running
	// in your AWS account
	expectedName := fmt.Sprintf("dfds-ci-%v", random.Random(1,500000))

	// Fixed to EU-Central-1, to avoid picking non-compliant region
	awsRegion := "eu-central-1" 
	terraformDir := "../identity/cognito"
	overridePath := filepath.Join(terraformDir, "override.tf")

	err = files.CopyFile("fixtures/terraform-backend/main.tf", overridePath)
	if err != nil {
		t.Fatal(err)
	}


	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: terraformDir,
		BackendConfig: map[string]interface{}{
			"path": remoteStateFile,
		},

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"user_pool_name": expectedName,
			"user_pool_domain_name": expectedName,
			"user_pool_client_name": "blaster",
			"user_pool_identity_provider_name": "DFDSAzureAD",
			"azure_ad_tenant_id": "73a99466-ad05-4221-9f90-e7142aa2f6c1",
			"build_callback_url": "https://build.dfds.com/sigin-oidc",
			"build_logout_url": "https://build.dfds.com/logout",
			"aws_region": awsRegion,
		},
		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
			"AWS_PROFILE": "dfds-playground",
		},
	}


	// Remove override as last thing
	defer os.Remove(overridePath)

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	//defer terraform.Destroy(t, terraformOptions)
	

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}
