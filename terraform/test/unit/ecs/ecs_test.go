package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
	// "github.com/gruntwork-io/terratest/modules/aws"
	"crypto/tls"

	"time"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	// "github.com/stretchr/testify/assert"
	"os"
	"testing"
)

func TestEcs(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
	})

	TerraformHiddenDir := ".terraform"
	const (
		AwsRegion = "us-east-1"
	)

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
		
		// run `terraform output` to get the value of an output variable
		// cluster_name := terraform.Output(t, terraformOptions, "cluster_name")
		
		// clusterName := aws.GetEcsCluster(t, AwsRegion, cluster_name)
		
		// // verify that the cluster is created
		// actualStatus := cluster_name
		// expectedStatus := *clusterName.ClusterName
		
		// assert.Equal(t, expectedStatus, actualStatus, "cluster not found.")
		
		alb_dns := terraform.Output(t, terraformOptions, "alb_dns")
		container_port := 4000

		// Verify the webpage returns a 200 status code
		maxRetries := 6
		timeBetweenRetries := 30 * time.Second
		url := fmt.Sprintf("http://%s:%d/api", alb_dns, container_port)
		expectedStatusCode := 200
		tlsConfig := tls.Config{
			InsecureSkipVerify: true,
		}
		expectedServerResponse := "\"test ok\""

		http_helper.HttpGetWithRetry(t, url, &tlsConfig, expectedStatusCode, expectedServerResponse, maxRetries, timeBetweenRetries)

}