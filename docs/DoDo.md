# Docker Image Security COnsiderations

We made sure to pin our docker images inorder to a specific version inorder {guarantee that the image won't change} and to avoid unprecedented changes, and reduce troubleshooting time.

Each image is also associated with a digest SHA — very much like a git commit. By specifying the SHA instead of the version tag, you can pull a specific version of the image. Something like:

```sh
docker pull ubuntu@<sha_digest_here>
```

## So why is this important?

Let’s take a docker-based CI/CD system for example. Imagine that your build pipeline is using docker containers to build/test/deploy your application. What this means is that your build/test/deploy commands will be running inside a docker container. Ideally you’re using very similar docker containers for building and running your application. For the sake of simplicity, let’s consider you’re always pulling the ubuntu:18.04 image to launch your build container off of.
—-
It’s your regular Monday morning and you have a couple of changes that you’d want to push through. You create your `PR` and wait for the build to get green… but it doesn’t. You see some weird error that you’ve never seen before but you go through the usual hoops to troubleshoot.

image maintainers may introduce changes that change the contents of a tag like 2.4-node or latest. Usually, this is done to fix bugs or introduce newer versions of essential software, like git and package managers for a language.

You can pin your job to run with a specific image SHA-256, which will guarantee the image won't change unless you update it yourself. This is done by removing the tag (e.g latest) and replacing it with the SHA-256 of the image, prefixed with @sha256:

### TradeOffs

By pinning the container version to a specific `SHA` you’re trading off “avoiding potential build failures” for “getting potential security patches for free”.

### Things that I need to do

1.add infracost cost badge [infracost](https://www.infracost.io/docs/infracost_cloud/readme_badge/)
2.add infracost github actions CI/CD [infracost-ci/cd](https://github.com/infracost/actions/)
3.add env vars to github secrets for infracost workflow setup
4.setup guardrails[cloud/guardrails/](https://www.infracost.io/docs/infracost_cloud/guardrails/)
5.setup cost policies[cost_policies/](https://www.infracost.io/docs/features/cost_policies/) e.g. "talk to John in FinOps for advice"
6.setup multiple environments for `dev`, `stage` & `production`. The `staging` and `production` environments will utilize different VPCs and possible there might be a management VPC to access either of the two.
7. Perform infrastructure testing such as `unit`, `integration` and `end2end` tests.

### We will also simulate the above nos. 2,4,5 during our final defence

### We implemented RBAC

This is just a way of restricting network access based on a person's role within an organization.

### Tips for building your own Terraform automation around delivery pipelines

- Your code should be stored in a version control system.
- Leverage the -input=false flag to disable interactive prompts. The command line, environment variables, or configuration files should provide any necessary input.
- Use a backend that supports remote Terraform State to allow runs on different machines and state locking for safety against race conditions.
- Prepare an environment to run Terraform with any dependencies pre-installed. To avoid downloading the provider plugins every time with the init command, use the flag -plugin-dir to provide the path of preconfigured plugins on the automation system.
- To allow changing the default backend configuration to deploy with different permissions or to different environments, you can utilize the -backend-config=path flag when initializing. If you only need to run checks on the Terraform files that don’t require initializing the backend (e.g., terraform validate), consider using the flag -backend=false.
- Integrate Terraform formatting, validating, linting, checking policies, and custom testing to the CI/CD pipelines to ensure your code conforms to your organization’s standards.
- Usually, CI/CD pipelines run on distributed systems. To ensure that we will apply the correct plan, we can output the plan to a file and package the whole terraform working directory after each plan. These artifacts will be stored somewhere to be fetched by the apply step to avoid accidentally applying different changes to the ones reviewed.
- Optionally, use the flag -auto-approve to apply the changes without human intervention.
- Use environment variables prefixed with `TF_VAR_` to pass any necessary values using the CI/CD tool mechanisms.
- Set the environment variable `TF_IN_AUTOMATION` to indicate that Terraform is running in automation mode. This adjusts the output of some commands to avoid outputting messages that are misleading in an automation environment
