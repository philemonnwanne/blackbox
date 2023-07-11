variable "environments" {
  type = map(string)

  default = {
    development = "dev"
    stage = "stage"
    production = "prod"
  }
}