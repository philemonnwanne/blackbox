package test

import (
	// "fmt"
	"testing"
	// "strings"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)
// Standard Go test, with the "Test" prefix and accepting the *testing.T struc
func TestS3Bucket(t *testing.T) {
	// your default aws region
	awsRegion := "us-east-1"
	tags := map[string]string {
		"Owner"       : "philemon nwanne",
		"Environment" : "stage",
	  }

	// construct the terraform options with default retryable errors
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{

		// where your terraform code lives
		TerraformDir: "../envs/stage",

		// set environment variables
		// EnvVars: map[string]string {
		// 	"AWS_DEFAULT_REGION": awsRegion,
		// },
	})

	// always clean up resources with "terraform destroy" whether test succeeds or fails
	defer terraform.Destroy(t, terraformOptions)

	// run "terraform init" & "terraform validate". Fail the test if there are any errors
	terraform.InitAndValidate(t, terraformOptions)

	// run "terraform apply". Fail the test if there are any errors
	terraform.Apply(t, terraformOptions)

	// get the bucket name so we can query AWS
	bucketName := terraform.Output(t, terraformOptions, "bucket_name")

	// confirm the bucket has been created & in the right region
	meOwn := aws.GetS3BucketTags(t, awsRegion, bucketName)

	// ensure that the s3 tags we get back from AWS are what we set them to
	assert.Equal(t, tags, meOwn)
}
