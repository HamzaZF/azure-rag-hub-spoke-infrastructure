/*
  variables.tf - Spoke AI Key Vault Module Variables

  This file defines all input variables for the AI spoke Key Vault module,
  including vault configuration, access policies, networking, and security settings.
*/

# =============================================================================
# NAMING CONVENTION
# =============================================================================

variable "naming_company" {
  description = "The company name for resource naming convention."
  type        = string
}

variable "naming_product" {
  description = "The product name for resource naming convention."
  type        = string
}

variable "naming_environment" {
  description = "The environment name for resource naming convention."
  type        = string
}

variable "naming_region" {
  description = "The region name for resource naming convention."
  type        = string
}

# =============================================================================
# KEY VAULT CONFIGURATION
# =============================================================================

variable "spoke_ai_key_vault_resource_group_name" {
  description = "The name of the resource group for the AI spoke Key Vault."
  type        = string
}

variable "spoke_ai_key_vault_location" {
  description = "The Azure region where the AI spoke Key Vault will be deployed."
  type        = string
}

variable "spoke_ai_key_vault_sku_name" {
  description = "The SKU name for the AI spoke Key Vault (standard or premium)."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.spoke_ai_key_vault_sku_name)
    error_message = "The spoke_ai_key_vault_sku_name must be either 'standard' or 'premium'."
  }
}

variable "spoke_ai_key_vault_enabled_for_disk_encryption" {
  description = "Whether the AI spoke Key Vault is enabled for Azure Disk Encryption."
  type        = bool
  default     = true
}

variable "spoke_ai_key_vault_soft_delete_retention_days" {
  description = "The number of days that items should be retained for soft delete in the AI spoke Key Vault."
  type        = number
  default     = 7
  validation {
    condition     = var.spoke_ai_key_vault_soft_delete_retention_days >= 7 && var.spoke_ai_key_vault_soft_delete_retention_days <= 90
    error_message = "The soft delete retention days must be between 7 and 90."
  }
}

variable "spoke_ai_key_vault_purge_protection_enabled" {
  description = "Whether purge protection is enabled for the AI spoke Key Vault."
  type        = bool
  default     = false
}

# =============================================================================
# NETWORKING CONFIGURATION
# =============================================================================

variable "spoke_ai_container_apps_subnet_id" {
  description = "The ID of the container apps subnet that should have access to the Key Vault."
  type        = string
}

variable "spoke_ai_key_vault_network_acls_bypass" {
  description = "Specifies which traffic can bypass the network rules for the Key Vault."
  type        = string
  default     = "AzureServices"
  validation {
    condition     = contains(["AzureServices", "None"], var.spoke_ai_key_vault_network_acls_bypass)
    error_message = "The network_acls_bypass must be either 'AzureServices' or 'None'."
  }
}

variable "spoke_ai_key_vault_network_acls_default_action" {
  description = "The default action to use when no network ACL rules match."
  type        = string
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.spoke_ai_key_vault_network_acls_default_action)
    error_message = "The network_acls_default_action must be either 'Allow' or 'Deny'."
  }
}

# =============================================================================
# RANDOM SUFFIX CONFIGURATION
# =============================================================================

variable "spoke_ai_key_vault_random_suffix_length" {
  description = "The length of the random suffix for the AI spoke Key Vault name."
  type        = number
}

variable "spoke_ai_key_vault_random_suffix_special" {
  description = "Whether to include special characters in the random suffix for Key Vault name."
  type        = bool
  default     = false
}

variable "spoke_ai_key_vault_random_suffix_upper" {
  description = "Whether to include uppercase characters in the random suffix for Key Vault name."
  type        = bool
  default     = false
}

# =============================================================================
# TAGS
# =============================================================================

variable "spoke_ai_key_vault_tags" {
  description = "A map of tags to assign to the AI spoke Key Vault resources."
  type        = map(string)
  default     = {}
}
