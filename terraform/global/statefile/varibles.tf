variable "table_name" {
  description = "name of the dynamodb table, must be unique"
  type = string
  default = "state-locker"
}