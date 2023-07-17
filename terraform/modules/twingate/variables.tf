variable "tg_api_key" {
  description = "a Twingate API token to programmatically manage your Twingate network"
  type = string
}

variable "tg_network" {
  description = "an existing physical network or VPC you would like to provide remote access to"
  type = string
}

variable "vpc_id" {
  description = "id of the VPC"
  type        = string
}

variable "cluster_name" {
  description = "name of the cluster"
  type        = string
  default     = "twingate-cluster"
}

variable "connector_name" {
  description = "name of the connector"
  type        = string
  default     = "tripevibe-connector"
}

# variable "task_name" {
#   description = "the tasks name"
#   default     = "twingate-connector"
# }

variable "twingate_image_uri" {
  description = "the twingate image url"
  type        = string
  default     = "twingate/connector:1"
}

variable "cluster_settings" {
  description = "configuration block(s) with cluster settings"
  type        = map(string)
  default = {
    name  = "containerInsights"
    value = "disabled"
  }
}

variable "system_req" {
  description = "memory and cpu requirements"
  type        = list(string)
  default = [
    256,
    512
  ]
}

variable "twingate_network" {
  description = "a single private network in Twingate that can have one or more Connectors and Resources assigned to it"
  type        = string
  # default     = "https://philemonnwanne.twingate.com"
  default = "philemonnwanne"
}
