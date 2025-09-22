/*
  main.tf - Spoke AI Key Vault Module

  This module creates an Azure Key Vault for the AI spoke container apps,
  providing secure storage for secrets, connection strings, API keys,
  and other sensitive configuration data needed by containerized AI workloads.

  Components:
  - Azure Key Vault with network restrictions
  - Access policies for managed identity
  - Integration with container apps subnet
  - Proper security configuration for AI workloads
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
# DATA SOURCES
# =============================================================================
data "azurerm_client_config" "current" {}

# =============================================================================
# KEY VAULT
# =============================================================================
# Azure Key Vault for container apps secrets and configuration

resource "azurerm_key_vault" "container_apps_kv" {
  name                          = replace("${module.naming.key_vault.name}${random_string.kv_suffix.result}", "-", "")
  location                      = var.spoke_ai_key_vault_location
  resource_group_name           = var.spoke_ai_key_vault_resource_group_name
  enabled_for_disk_encryption   = var.spoke_ai_key_vault_enabled_for_disk_encryption
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = var.spoke_ai_key_vault_soft_delete_retention_days
  purge_protection_enabled      = var.spoke_ai_key_vault_purge_protection_enabled
  public_network_access_enabled = false

  sku_name                  = var.spoke_ai_key_vault_sku_name
  enable_rbac_authorization = true

  # Access policy for current user/service principal (for deployment)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover"
    ]

    storage_permissions = [
      "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover"
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover"
    ]
  }
}

# =============================================================================
# RANDOM SUFFIX
# =============================================================================
# Random suffix for Key Vault name uniqueness

resource "random_string" "kv_suffix" {
  length  = var.spoke_ai_key_vault_random_suffix_length
  special = var.spoke_ai_key_vault_random_suffix_special
  upper   = var.spoke_ai_key_vault_random_suffix_upper
}
