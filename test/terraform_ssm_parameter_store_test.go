package test

import (
	"fmt"
	"io/ioutil"
	"path/filepath"
	"testing"

	dfds "github.com/dfds/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// An example of how to test the Terraform module in examples/terraform-aws-example using Terratest.
func TestAwsSsmParameterStore(t *testing.T) {
	t.Parallel()

	stateDirectory, err := ioutil.TempDir("", t.Name())
	if err != nil {
		t.Fatal(err)
	}
	remoteStateFile := filepath.Join(stateDirectory, "backend.tfstate")

	// Give this EC2 Instance a unique ID for a name tag so we can distinguish it from any other EC2 Instance running
	// in your AWS account
	expectedName := fmt.Sprintf("test-name-%s", random.UniqueId())
	expectedDescription := fmt.Sprintf("test-description-%s", random.UniqueId())
	expectedValue := fmt.Sprintf("test-value-%s", random.UniqueId())

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := aws.GetRandomRegion(t, nil, nil)
	terraformDir := "../_sub/security/ssm-parameter-store"

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: terraformDir,
		BackendConfig: map[string]interface{}{
			"path": remoteStateFile,
		},

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"key_name": expectedName,
			"key_description": expectedDescription,
			"key_value": expectedValue,
		},
		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// // Remove override as last thing
	// defer os.Remove(overridePath)

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable

	value := dfds.GetParameter(t, awsRegion, expectedName)
	assert.Equal(t, expectedValue, value)
}
