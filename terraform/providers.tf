terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.0"
    }
    twingate = {
      source  = "Twingate/twingate"
      version = "1.1.3-rc3"
    }
  }
  required_version = ">= 1.1.0"
}