terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
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
  }
  required_version = ">= 1.1.0"
}

# Define the MongoDB Atlas Provider
terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
  required_version = ">= 0.13"
}