variable "location" {
  type    = string
  default = "westeurope"
}

variable "project" {
  type    = string
  default = "contoso"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "address_space" {
  type    = string
  default = "172.17.0.0/16"
}

variable "node_pool_count" {
  type    = number
  default = 1

  validation {
    condition     = var.node_pool_count > 0 && var.node_pool_count < 10
    error_message = "Node pool count must be within range [1..9]."
  }
}

variable "dns_zone_name" {
  type = string
}

variable "ssl_key_vault_secret_name" {
  type = string
}

variable "ssl_key_vault_name" {
  type = string
}

variable "ssl_key_vault_resource_group_name" {
  type = string
}

variable "dns_zone_resource_group_name" {
  type = string
}
