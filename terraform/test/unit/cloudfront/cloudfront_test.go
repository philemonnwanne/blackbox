package test

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudfront"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"os"
	"testing"
)

func TestCloudFront(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
	})

	TerraformHiddenDir := ".terraform"

	// at the end of the test clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// do `terraform init` only on first run
	folderInfo, err := os.Stat(TerraformHiddenDir)

	// run `Terraform INIT` only on the first run, then `APPLY` on subsequent runs
	if os.IsNotExist(err) {
		fmt.Println("Folder does not exist:", folderInfo)

		// run `terraform init & apply` and fail if there are any errors
		terraform.InitAndApply(t, terraformOptions)

		// // TODO: implement recursive removal of the `.terraform` directory on terraform INIT failure
		// moduleError := "Module not installed"
		// if err != nil && errors.New(moduleError) {
		// 	os.RemoveAll("./terraform")
		// }
	}

	fmt.Println("FOLDER WAS FOUND @:", TerraformHiddenDir)

	// run `terraform apply` and fail if there are any errors
	terraform.Apply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	cloudfrontId := terraform.Output(t, terraformOptions, "cloudfront_id")

	// FUNCTION TO CHECK DISTRIBUTION EXISTENCE

	var cloud_front = func() (cloudfront_id string) {
		// initialize the session that the SDK uses to load credentials from the shared credentials file
		sess, err := session.NewSession(&aws.Config{
			Region: aws.String("us-east-1"),
		})

		if err != nil {
			fmt.Println("Error creating session ", err)
			// return err.Error()
		}

		// create a new Amazon cloudfront service client:
		svc := cloudfront.New(sess)

		distributionId := &cloudfrontId

		input := &cloudfront.GetDistributionInput{
			Id: distributionId,
		}

		result, err := svc.GetDistribution(input)
		if err != nil {
			if aerr, ok := err.(awserr.Error); ok {
				switch aerr.Code() {
				case cloudfront.ErrCodeNoSuchDistribution:
					fmt.Println(cloudfront.ErrCodeNoSuchDistribution, aerr.Error())
				case cloudfront.ErrCodeAccessDenied:
					fmt.Println(cloudfront.ErrCodeAccessDenied, aerr.Error())
				default:
					fmt.Println(aerr.Error())
				}
			} else {
				// Print the error, cast err to awserr.Error
				fmt.Println(err.Error())
			}
			return
		}

		return *result.Distribution.Id
	}

	// Verify that our distribution has been enabled
	actualStatus := cloud_front()
	expectedStatus := cloudfrontId

	assert.Equal(t, expectedStatus, actualStatus, "found the distribution.")
}
