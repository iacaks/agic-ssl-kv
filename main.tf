terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.98.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "mdmsft"
    storage_account_name = "mdmsft"
    container_name       = "tfstate"
    key                  = "megatron"
    subscription_id      = "6f3a143b-51cc-4a89-aa5a-3c98bb3f5e46"
    tenant_id            = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  }
}

locals {
  resource_suffix = "${var.project}-${var.environment}-${var.location}"
  context_name    = "${var.project}-${var.environment}"
}

provider "azurerm" {
  features {}
  subscription_id = "6f3a143b-51cc-4a89-aa5a-3c98bb3f5e46"
  tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd011db47"
}

data "azurerm_client_config" "main" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_suffix}"
  location = var.location
  tags = {
    project     = var.project
    environment = var.environment
    location    = var.location
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.resource_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}