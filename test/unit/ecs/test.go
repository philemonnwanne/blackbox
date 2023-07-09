package test

import(
	"testing"
	// "github.com/aws/aws-sdk-go/service/ecs"
	// "fmt"
	// "strings"

	// "github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/gruntwork-io/terratest/modules/aws"
	// "github.com/stretchr/testify/assert"
)

func TestCloudfront(t *testing.T) {
	// t.Parallel()
	url := terraform. Output(t, cloudfrontOptions, "url")

	// construct the terraform options with default retryable errors
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		
		// where the cloudfront-module code lives
		TerraformDir: "../modules/cloudfront",
	})
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
}