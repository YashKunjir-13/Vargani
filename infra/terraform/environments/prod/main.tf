terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type    = string
  default = "prod"
}

output "prod_environment_status" {
  value = "Prod HA Terraform foundation defined"
}
