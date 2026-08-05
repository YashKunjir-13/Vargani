terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type    = string
  default = "staging"
}

output "staging_environment_status" {
  value = "Staging Terraform foundation defined"
}
