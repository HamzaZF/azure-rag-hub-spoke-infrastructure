/*
  variables.tf (Spoke AI Private Endpoint - Storage)

  This file defines all input variables for the Kelix Azure Spoke AI Storage Private Endpoint submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

variable "spoke_ai_pe_storage_location" {
  description = "The Azure region where AI storage private endpoint will be deployed."
  type        = string
}

variable "spoke_ai_pe_storage_resource_group_name" {
  description = "The name of the resource group where AI storage private endpoint will be created."
  type        = string
}

variable "spoke_ai_pe_storage_subnet_id" {
  description = "The subnet ID where the AI storage private endpoint will be deployed."
  type        = string
}

variable "spoke_ai_pe_storage_account_id" {
  description = "The ID of the AI storage account for the private endpoint."
  type        = string
}

variable "spoke_ai_pe_storage_vnet_id" {
  description = "The VNet ID for the DNS zone virtual network link."
  type        = string
}

variable "spoke_ai_pe_storage_private_dns_zone_id" {
  description = "The private DNS zone ID for the storage account (optional, will create if not provided)."
  type        = string
  default     = null
}

# Random suffix configuration for private endpoint
variable "spoke_ai_pe_storage_pe_random_suffix_length" {
  description = "The length of the random suffix for the storage private endpoint name."
  type        = number
  default     = 4
}

variable "spoke_ai_pe_storage_pe_random_suffix_special" {
  description = "Whether to include special characters in the storage PE random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_pe_storage_pe_random_suffix_upper" {
  description = "Whether to include uppercase letters in the storage PE random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for private service connection
variable "spoke_ai_pe_storage_psc_random_suffix_length" {
  description = "The length of the random suffix for the storage private service connection name."
  type        = number
  default     = 4
}

variable "spoke_ai_pe_storage_psc_random_suffix_special" {
  description = "Whether to include special characters in the storage PSC random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_pe_storage_psc_random_suffix_upper" {
  description = "Whether to include uppercase letters in the storage PSC random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for DNS zone group
variable "spoke_ai_pe_storage_dns_group_random_suffix_length" {
  description = "The length of the random suffix for the storage DNS zone group name."
  type        = number
  default     = 4
}

variable "spoke_ai_pe_storage_dns_group_random_suffix_special" {
  description = "Whether to include special characters in the storage DNS group random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_pe_storage_dns_group_random_suffix_upper" {
  description = "Whether to include uppercase letters in the storage DNS group random suffix."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Naming Convention
# -----------------------------------------------------------------------------

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