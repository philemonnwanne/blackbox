variable "env_names" {
  type = map(string)

  default = {
    development = "dev-env"
    staging = "staging-env"
    production = "prod-env"
  }
}