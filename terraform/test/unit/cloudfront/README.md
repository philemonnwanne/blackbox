# Test Procedure

Replace the variable `distributionId` with your desired CloudFront distribution ID, if you want to test a pre-existing distribution. You can also use the default pointer variable in the test code, which automatically picks up the cloudfront distribution ID from terraforms outputs.

To make use of your own custom ID modify the following lines as such.

➖ Before

```go
distributionId := &cloudfront_id

input := &cloudfront.GetDistributionInput{
    Id: distributionId,
}
```

✅ After

```go
distributionId := "ID here"

input := &cloudfront.GetDistributionInput{
    Id: &distributionId,
}
```

## Timeout Fix

Go’s package testing has a default timeout of 10 minutes, after which it forcibly kills your tests — even your `cleanup` code won’t run! It’s not uncommon for infrastructure tests to take longer than 10 minutes, so you’ll almost always want to increase the timeout by using the `-timeout` option.

`Note:` Always run cloudfront tests with a timeout of at least `30mins` as distributions usually take a long time to deploy.

```bash
go test -timeout 30m
```
