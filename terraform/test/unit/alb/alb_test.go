package test

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/elbv2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"os"
	"strings"
	"testing"
)

func TestLoadBalancer(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
	})

	TerraformHiddenDir := ".terraform"

	// at the end of the test clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// do `terraform init` only on first run
	folderInfo, err := os.Stat(TerraformHiddenDir)

// func (fun) (f, *this entire function block is for fun.FuN) {
	
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
// }

	// Run `terraform output` to get the value of an output variable
	albArn := terraform.Output(t, terraformOptions, "alb_arn")

	// FUNCTION TO CHECK IF LOAD BALANCER IS UP
	var elbv2 = func() (alb_arn string) {
		// initialize the session that the SDK uses to load credentials from the shared credentials file
		sess, err := session.NewSession(&aws.Config{
			Region: aws.String("us-east-1"),
		})

		if err != nil {
			fmt.Println("Error creating session ", err)
			// return err.Error()
		}

		// create a new Amazon cloudfront service client:
		svc := elbv2.New(sess)

		loadBalancerArn := strings.Fields(albArn)

		input := &elbv2.DescribeLoadBalancersInput{
			LoadBalancerArns: aws.StringSlice(loadBalancerArn),
		}

		desired_state := "active"
		result, err := svc.DescribeLoadBalancers(input)
		alb_state := *result.LoadBalancers[0].State.Code

		// make sure load balancer is in active state and has no errors
		if err != nil && alb_state == desired_state {
			if aerr, ok := err.(awserr.Error); ok {
				switch aerr.Code() {
				case elbv2.ErrCodeLoadBalancerNotFoundException:
					fmt.Println(elbv2.ErrCodeLoadBalancerNotFoundException, aerr.Error())
				default:
					fmt.Println(aerr.Error())
				}
			} else {
				// Print the error, cast err to awserr.Error
				fmt.Println(err.Error())
			}
			return
		}

		return *result.LoadBalancers[0].LoadBalancerArn
	}

	// Verify that the load balancer is up
	actualStatus := elbv2()
	expectedStatus := albArn

	assert.Equal(t, expectedStatus, actualStatus, "alb not found.")
}
