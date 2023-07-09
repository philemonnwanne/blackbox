package test

import(
	"testing"
	// "fmt"
	// "strings"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
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

func TestAlb(t *testing.T) {
	// t.Parallel()
	url := terraform. Output(t, albOptions, "url")

	return &terraform.Options{
		TerraformDir:	"./examples/proxy-app"
		Vars: map [string]interface{}{
		"url_to-proxy": url,
		},
	}
}

func TestEcs(t *testing.T) {
	// t.Parallel()
	url := terraform. Output(t, albOptions, "url")

	return &terraform.Options{
		TerraformDir:	"./examples/proxy-app"
		Vars: map [string]interface{}{
		"url_to-proxy": url,
		},
	}
}

func TestGrafana(t *testing.T) {
	// t.Parallel()
	url := terraform. Output(t, albOptions, "url")

	return &terraform.Options{
		TerraformDir:	"./examples/proxy-app"
		Vars: map [string]interface{}{
		"url_to-proxy": url,
		},
	}
}

func TestRoute53(t *testing.T) {
	// t.Parallel()
	url := terraform. Output(t, albOptions, "url")

	return &terraform.Options{
		TerraformDir:	"./examples/proxy-app"
		Vars: map [string]interface{}{
		"url_to-proxy": url,
		},
	}
}

func TestSecurity(t *testing.T) {
	// t.Parallel()
	url := terraform. Output(t, albOptions, "url")

	return &terraform.Options{
		TerraformDir:	"./examples/proxy-app"
		Vars: map [string]interface{}{
		"url_to-proxy": url,
		},
	}
}

func TestVpc(t *testing.T) {
	// t.Parallel()
	url := terraform. Output(t, albOptions, "url")

	return &terraform.Options{
		TerraformDir:	"./examples/proxy-app"
		Vars: map [string]interface{}{
		"url_to-proxy": url,
		},
	}
}