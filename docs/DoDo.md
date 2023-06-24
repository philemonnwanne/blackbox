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

- add infracost cost badge [infracost](https://www.infracost.io/docs/infracost_cloud/readme_badge/)
- 