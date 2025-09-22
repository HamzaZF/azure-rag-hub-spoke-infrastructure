/*
  variables.tf - Spoke AI Storage Account Module Variables

  This file defines all input variables for the AI spoke storage account module,
  including storage configuration, networking integration, and security settings.
*/

# =============================================================================
# RESOURCE GROUP AND LOCATION
# =============================================================================

variable "spoke_ai_storage_resource_group_name" {
  description = "The name of the resource group for AI spoke storage resources."
  type        = string
}

variable "spoke_ai_storage_location" {
  description = "The Azure region for AI spoke storage resources."
  type        = string
}

# =============================================================================
# STORAGE ACCOUNT CONFIGURATION
# =============================================================================

variable "spoke_ai_storage_account_tier" {
  description = "The tier of the storage account (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "spoke_ai_storage_account_replication_type" {
  description = "The replication type for the storage account."
  type        = string
  default     = "LRS"
}

variable "spoke_ai_storage_account_kind" {
  description = "The kind of storage account (StorageV2, BlobStorage, FileStorage, etc.)."
  type        = string
  default     = "StorageV2"
}

# Random suffix configuration for storage account
variable "spoke_ai_storage_random_suffix_length" {
  description = "The length of the random suffix for the storage account name."
  type        = number
  default     = 4
}

variable "spoke_ai_storage_random_suffix_special" {
  description = "Whether to include special characters in the storage account random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_storage_random_suffix_upper" {
  description = "Whether to include uppercase letters in the storage account random suffix."
  type        = bool
  default     = false
}

# =============================================================================
# NETWORKING INTEGRATION
# =============================================================================

variable "spoke_ai_storage_subnet_id" {
  description = "The ID of the subnet for the storage account private endpoint."
  type        = string
}

variable "spoke_ai_storage_vnet_id" {
  description = "The ID of the virtual network for DNS zone linking."
  type        = string
}

variable "spoke_ai_storage_allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the AI storage account."
  type        = list(string)
  default     = []
}

variable "spoke_ai_storage_allowed_ip_rules" {
  description = "List of allowed IP addresses for storage account access."
  type        = list(string)
  default     = []
}

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