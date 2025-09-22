/*
  main.tf - Spoke AI Storage Account Module

  This module creates the Azure Storage Account for AI workloads with
  table storage capabilities and comprehensive security controls.

  Components:
  - Storage account with table storage support
  - Network security with private endpoint integration
  - Managed identity for secure access
  - Comprehensive tagging and monitoring
*/

# =============================================================================
# NAMING
# =============================================================================
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "ai"]
  suffix = [var.naming_region]
}

# =============================================================================
# STORAGE ACCOUNT
# =============================================================================
# Core storage account for AI data persistence

resource "azurerm_storage_account" "storage_account" {
  name                     = "${module.naming.storage_account.name}${random_string.storage_suffix.result}"
  resource_group_name      = var.spoke_ai_storage_resource_group_name
  location                 = var.spoke_ai_storage_location
  account_tier             = var.spoke_ai_storage_account_tier
  account_replication_type = var.spoke_ai_storage_account_replication_type
  account_kind             = var.spoke_ai_storage_account_kind

  # Security and compliance
  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "random_string" "storage_suffix" {
  length  = var.spoke_ai_storage_random_suffix_length
  special = var.spoke_ai_storage_random_suffix_special
  upper   = var.spoke_ai_storage_random_suffix_upper
}

# =============================================================================
# TABLE STORAGE
# =============================================================================

 