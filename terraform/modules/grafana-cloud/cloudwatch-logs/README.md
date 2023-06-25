# Automatically configure lambda-promtail using Terraform

You’ll find a Terraform snippet in this section that can be used to provision all resources necessary to deploy `lambda-promtail` in your AWS account.

To run the Terraform setup:

Configure the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html). Remember to set the correct AWS region where `lambda-promtail` should run and pull CloudWatch logs from.

Copy this snippet into a Terraform file:

```ruby
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_region" "current" {}

resource "aws_s3_object_copy" "lambda_promtail_zipfile" {
  bucket = var.s3_bucket
  key    = var.s3_key
  source = "grafanalabs-cf-templates/lambda-promtail/lambda-promtail.zip"
}

resource "aws_iam_role" "lambda_promtail_role" {
  name = "GrafanaLabsCloudWatchLogsIntegration"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_promtail_policy_logs" {
  name = "lambda-logs"
  role = aws_iam_role.lambda_promtail_role.name
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:logs:*:*:*",
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "lambda_promtail_log_group" {
  name              = "/aws/lambda/GrafanaCloudLambdaPromtail"
  retention_in_days = 14
}

resource "aws_lambda_function" "lambda_promtail" {
  function_name = "GrafanaCloudLambdaPromtail"
  role          = aws_iam_role.lambda_promtail_role.arn

  timeout     = 60
  memory_size = 128

  handler   = "main"
  runtime   = "go1.x"
  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  environment {
    variables = {
      WRITE_ADDRESS = var.write_address
      USERNAME      = var.username
      PASSWORD      = var.password
      KEEP_STREAM   = var.keep_stream
      BATCH_SIZE    = var.batch_size
      EXTRA_LABELS  = var.extra_labels
    }
  }

  depends_on = [
    aws_s3_object_copy.lambda_promtail_zipfile,
    aws_iam_role_policy.lambda_promtail_policy_logs,
    aws_cloudwatch_log_group.lambda_promtail_log_group,
  ]
}

resource "aws_lambda_function_event_invoke_config" "lambda_promtail_invoke_config" {
  function_name          = aws_lambda_function.lambda_promtail.function_name
  maximum_retry_attempts = 2
}

resource "aws_lambda_permission" "lambda_promtail_allow_cloudwatch" {
  statement_id  = "lambda-promtail-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_promtail.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
}

# This block allows for easily subscribing to multiple log groups via the `log_group_names` var.
# However, if you need to provide an actual filter_pattern for a specific log group you should
# copy this block and modify it accordingly.
resource "aws_cloudwatch_log_subscription_filter" "lambda_promtail_logfilter" {
  for_each        = toset(var.log_group_names)
  name            = "lambda_promtail_logfilter_${each.value}"
  log_group_name  = each.value
  destination_arn = aws_lambda_function.lambda_promtail.arn
  # required but can be empty string
  filter_pattern = ""
  depends_on     = [aws_iam_role_policy.lambda_promtail_policy_logs]
}

output "role_arn" {
  value       = aws_lambda_function.lambda_promtail.arn
  description = "The ARN of the Lambda function that runs lambda-promtail."
}
```

Copy the following snippet into a `variables.tf` file. You’ll need to paste here some of the values displayed in the installation instructions (e.g. the `write_address`, `username` and `password`).

```ruby
variable "write_address" {
  type        = string
  description = "This is the Grafana Cloud Loki URL that logs will be forwarded to."
  default     = ""
}

variable "username" {
  type        = string
  description = "The basic auth username for Grafana Cloud Loki."
  default     = ""
}

variable "password" {
  type        = string
  description = "The basic auth password for Grafana Cloud Loki (your Grafana.com API Key)."
  sensitive   = true
  default     = ""
}

variable "s3_bucket" {
  type        = string
  description = "The name of the bucket where to upload the 'lambda-promtail.zip' file."
  default     = ""
}

variable "s3_key" {
  type        = string
  description = "The desired path where to upload the 'lambda-promtail.zip' file (defaults to the root folder)."
  default     = "lambda-promtail.zip"
}

variable "log_group_names" {
  type        = list(string)
  description = "List of CloudWatch Log Group names to create Subscription Filters for (ex. /aws/lambda/my-log-group)."
  default     = []
}

variable "keep_stream" {
  type        = string
  description = "Determines whether to keep the CloudWatch Log Stream value as a Loki label when writing logs from lambda-promtail."
  default     = "false"
}

variable "extra_labels" {
  type        = string
  description = "Comma separated list of extra labels, in the format 'name1,value1,name2,value2,...,nameN,valueN' to add to entries forwarded by lambda-promtail."
  default     = ""
}

variable "batch_size" {
  type        = string
  description = "Determines when to flush the batch of logs (bytes)."
  default     = ""
}
```

Configure variables according to their descriptions. Note that all resources must be in the same AWS region (CloudWatch Log Group, Lambda function, S3 bucket for `lambda-promtail.zip`). Finally, run the terraform apply command:

```sh
terraform apply -var-file="variables.tf"
```

Once the `terraform apply` command has finished creating the resources, it will output the `role_arn` of the Lambda function that runs `lambda-promtail`.

The Terraform snippets above should get you started with a basic configuration for `lambda-promtail`. For additional setup (e.g. VPC subnets and security groups) read through this extended [example Terraform](https://github.com/grafana/loki/blob/main/tools/lambda-promtail/main.tf) file.

## Log labels

CloudWatch logs forwarded to Grafana Cloud Loki the following special labels assigned to them:

`__aws_cloudwatch_log_group`: The associated Cloudwatch Log Group for this log.

`__aws_cloudwatch_owner`: The AWS ID of the owner of this log.

`__aws_cloudwatch_log_stream`: The associated Cloudwatch Log Stream for this log (if KEEP_STREAM is set to true).

Both the CloudFormation and Terraform setup allow to specify “extra labels” (as key-value pairs) that will be added to logs streamed by `lambda-promtail`. These extra labels will take the form `__extra_<name>=<value>`.
