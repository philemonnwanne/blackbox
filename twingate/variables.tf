variable "tg_api_key" {
  description = "a Twingate API token to programmatically manage your Twingate network"
  type = string
}

variable "tg_network" {
  description = "an existing physical network or VPC you would like to provide remote access to"
  type = string
}