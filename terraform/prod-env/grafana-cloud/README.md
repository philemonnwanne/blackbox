# CloudWatch metrics integration for Grafana Cloud

The CloudWatch integration allows you to scrape AWS CloudWatch metrics without installing the Grafana agent. You can create multiple configurations called “scrape jobs” to separate concerns. Please note that we can only discover metrics for AWS resources that have tags applied to them. For more information, see the [AWS docs](https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html).

The CloudWatch integration packages together many dashboards, a few of which reference [Monitoring Artist](https://github.com/monitoringartist/grafana-aws-cloudwatch-dashboards).

## CloudWatch integration vs CloudWatch data source

Grafana Cloud offers two solutions for visualizing your CloudWatch metrics, the integration or the data source. The data source allows you to keep your data in CloudWatch and build dashboards, rules, and alerts without pulling the data in to Grafana Cloud. The integration continuously pulls data from CloudWatch and pushes it to your Grafana Cloud Hosted Metrics Instance. This allows you to pull in your CloudWatch data from multiple AWS regions, query, and alert on it using the power of promql. The integration also gives you the ability to ingest the Tags from your AWS instance and make them available for querying/alerting.
