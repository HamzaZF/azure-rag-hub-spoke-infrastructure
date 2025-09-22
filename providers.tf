terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.7"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    # azapi = {
    #   source = "azure/azapi"
    # }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
    key_vault {
      purge_soft_deleted_certificates_on_destroy = true
      recover_soft_deleted_certificates          = true
    }
  }
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

provider "azuread" {
  # Azure AD provider configuration
}

# provider "azapi" {
# }



provider "docker" {
  # Docker provider will use the default Docker daemon
  # Make sure Docker is running on your machine
}