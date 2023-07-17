terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "~> .0"
    }
    twingate = {
      source  = "Twingate/twingate"
      version = "1.1.3-rc3"
    }
  }
}

# configure Twingate Provider
provider "twingate" {
  api_token = var.tg_api_key
  network   = var.tg_network
}

# create the twingate remote network
resource "twingate_remote_network" "tripvibe_network" {
  name = "TRIP-VIBE Network"
}

# create the connector
resource "twingate_connector" "tripvibe_connector" {
  remote_network_id = twingate_remote_network.tripvibe_network.id
  name = var.connector_name
}

# create the tokens which the remote connector will use to communicate with twingate
resource "twingate_connector_tokens" "tripvibe_connector_tokens" {
  connector_id = twingate_connector.tripvibe_connector.id
}

# create a Twingate group
# resource "twingate_group" "tripvibe_group" {
#   name = "admin group"
# }

# create a service account for github actions
# resource "twingate_service_account" "github_actions_dev" {
#   name = "Github Actions DEV"
# }

# # create a Twingate resource
# resource "twingate_resource" "tripvibe_resource" {
#   name              = "TRIPEVIBE-SERVER"
#   address           = aws_instance.test.private_ip
#   remote_network_id = twingate_remote_network.tripvibe_network.id

#   protocols {
#     allow_icmp = true
#     tcp {
#       policy = "RESTRICTED"
#       ports  = ["22"]
#     }
#     udp {
#       policy = "ALLOW_ALL"
#     }
#   }

#   access {
#     group_ids = [twingate_group.tripvibe_group.id]
#     # service_account_ids = [twingate_service_account.github_actions_dev.id]
#   }
# }