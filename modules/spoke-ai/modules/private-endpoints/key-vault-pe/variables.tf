/*
  variables.tf - Spoke AI Key Vault Private Endpoint Module Variables

  This file defines all input variables for the AI spoke Key Vault private endpoint module,
  including endpoint configuration, DNS settings, networking, and naming conventions.
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
# PRIVATE ENDPOINT CONFIGURATION
# =============================================================================

variable "spoke_ai_pe_key_vault_location" {
  description = "The Azure region where the AI spoke Key Vault private endpoint will be deployed."
  type        = string
}

variable "spoke_ai_pe_key_vault_resource_group_name" {
  description = "The name of the resource group for the AI spoke Key Vault private endpoint."
  type        = string
}

variable "spoke_ai_pe_key_vault_subnet_id" {
  description = "The ID of the subnet where the AI spoke Key Vault private endpoint will be created."
  type        = string
}

variable "spoke_ai_pe_key_vault_id" {
  description = "The ID of the AI spoke Key Vault for which to create the private endpoint."
  type        = string
}

# =============================================================================
# PRIVATE ENDPOINT RANDOM SUFFIX CONFIGURATION
# =============================================================================

variable "spoke_ai_pe_key_vault_pe_random_suffix_length" {
  description = "The length of the random suffix for the AI spoke Key Vault private endpoint name."
  type        = number
  default     = 4
  validation {
    condition     = var.spoke_ai_pe_key_vault_pe_random_suffix_length > 0 && var.spoke_ai_pe_key_vault_pe_random_suffix_length <= 8
    error_message = "The random suffix length must be between 1 and 8."
  }
}

variable "spoke_ai_pe_key_vault_pe_random_suffix_special" {
  description = "Whether to include special characters in the random suffix for Key Vault private endpoint name."
  type        = bool
  default     = false
}

variable "spoke_ai_pe_key_vault_pe_random_suffix_upper" {
  description = "Whether to include uppercase characters in the random suffix for Key Vault private endpoint name."
  type        = bool
  default     = false
}

# =============================================================================
# DNS GROUP RANDOM SUFFIX CONFIGURATION
# =============================================================================

variable "spoke_ai_pe_key_vault_dns_group_random_suffix_length" {
  description = "The length of the random suffix for the AI spoke Key Vault private endpoint DNS group name."
  type        = number
  default     = 4
  validation {
    condition     = var.spoke_ai_pe_key_vault_dns_group_random_suffix_length > 0 && var.spoke_ai_pe_key_vault_dns_group_random_suffix_length <= 8
    error_message = "The DNS group random suffix length must be between 1 and 8."
  }
}

variable "spoke_ai_pe_key_vault_dns_group_random_suffix_special" {
  description = "Whether to include special characters in the random suffix for Key Vault private endpoint DNS group name."
  type        = bool
  default     = false
}

variable "spoke_ai_pe_key_vault_dns_group_random_suffix_upper" {
  description = "Whether to include uppercase characters in the random suffix for Key Vault private endpoint DNS group name."
  type        = bool
  default     = false
}

# =============================================================================
# TAGS
# =============================================================================

variable "spoke_ai_pe_key_vault_tags" {
  description = "A map of tags to assign to the AI spoke Key Vault private endpoint resources."
  type        = map(string)
  default     = {}
}
