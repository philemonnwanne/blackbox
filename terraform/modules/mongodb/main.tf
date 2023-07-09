# define the MongoDB Atlas provider
terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
  required_version = ">= 0.13"
}

# create a project
resource "mongodbatlas_project" "atlas-project" {
  org_id = var.atlas_org_id
  name = var.atlas_project_name
}

# create a database user
resource "mongodbatlas_database_user" "db-user" {
  username = "user-1"
  password = random_password.db-user-password.result
  project_id = mongodbatlas_project.atlas-project.id
  auth_database_name = "admin"
  roles {
    role_name     = "readWrite"
    database_name = "${var.atlas_project_name}-db"
  }
}

# create a random database password
resource "random_password" "db-user-password" {
  length = 16
  special = true
  override_special = "_%@"
}

# create database IP access list 
resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.atlas-project.id
  # ip_address = var.ip_address // enable only in prod if necessary
  cidr_block = var.cidr_block
  comment    = "cidr block for tf acc testing"
}

# create an Atlas advanced cluster 
resource "mongodbatlas_advanced_cluster" "atlas-cluster" {
  project_id = mongodbatlas_project.atlas-project.id
  name = "${var.atlas_project_name}-${var.environment}-cluster"
  cluster_type = "REPLICASET"
  backup_enabled = true
  mongo_db_major_version = var.mongodb_version
  termination_protection_enabled = false // only set to true in prod
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.cluster_instance_size_name
        node_count    = 3
      }
      # analytics_specs {
      #   instance_size = var.cluster_instance_size_name
      #   node_count    = 1
      # }
      priority      = 7
      provider_name = var.cloud_provider
      region_name   = var.atlas_region
    }
  }
}