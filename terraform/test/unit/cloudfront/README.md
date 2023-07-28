# Timeout Fix

Go’s package testing has a default timeout of 10 minutes, after which it forcibly kills your tests—even your `cleanup` code won’t run! It’s not uncommon for infrastructure tests to take longer than 10 minutes, so you’ll almost always want to increase the timeout by using the `-timeout` option.

`Note:` Always run cloudfront tests with a timeout of at least `30mins` as distributions usually take a long to deploy.

```bash
go test -timeout 30m
```
