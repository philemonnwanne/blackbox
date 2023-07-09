package test

import (
	// "fmt"
	"testing"
	// "strings"

	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/gruntwork-io/terratest/modules/aws"
	// "github.com/stretchr/testify/assert"
)

// Standard Go test, with the "Test" prefix and accepting the *testing.T struc
func TestModules(t *testing.T) {
	t.Parallel()

	// construct the terraform options with default retryable errors
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{

		// where your terraform code lives
		TerraformDir: "../envs/stage",
	},)

	albOptions := TestALB(t, terraformOptions)
	
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	
	cloudfrontOptions := TestCloudFront(t, albOptions, terraformOptions)

		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	
	ecsOptions:= TestECS(cloudfrontOptions)

		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	
}