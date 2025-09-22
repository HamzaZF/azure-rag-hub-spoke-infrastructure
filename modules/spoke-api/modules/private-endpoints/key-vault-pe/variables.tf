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

variable "spoke_api_pe_key_vault_location" {
  description = "The location for the key vault private endpoint."
  type        = string
}

variable "spoke_api_pe_key_vault_resource_group_name" {
  description = "The resource group name for the key vault private endpoint."
  type        = string
}

variable "spoke_api_pe_key_vault_subnet_id" {
  description = "The subnet ID for the key vault private endpoint."
  type        = string
}

variable "spoke_api_pe_key_vault_id" {
  description = "The ID of the key vault private endpoint."
  type        = string
}

# define variables for

# var.spoke_api_pe_key_vault_pe_random_suffix_special
# var.spoke_api_pe_key_vault_pe_random_suffix_upper
# var.spoke_api_pe_key_vault_dns_group_random_suffix_length
# var.spoke_api_pe_key_vault_dns_group_random_suffix_special
# var.spoke_api_pe_key_vault_dns_group_random_suffix_upper

variable "spoke_api_pe_key_vault_pe_random_suffix_length" {
  description = "The length of the random suffix for the key vault private endpoint."
  type        = number
}

variable "spoke_api_pe_key_vault_pe_random_suffix_special" {
  description = "The special characters for the key vault private endpoint random suffix."
  type        = string
}

variable "spoke_api_pe_key_vault_pe_random_suffix_upper" {
  description = "The uppercase characters for the key vault private endpoint random suffix."
  type        = string
}

variable "spoke_api_pe_key_vault_dns_group_random_suffix_length" {
  description = "The length of the random suffix for the key vault private endpoint DNS group."
  type        = number
}

variable "spoke_api_pe_key_vault_dns_group_random_suffix_special" {
  description = "The special characters for the key vault private endpoint DNS group random suffix."
  type        = string
}

variable "spoke_api_pe_key_vault_dns_group_random_suffix_upper" {
  description = "The uppercase characters for the key vault private endpoint DNS group random suffix."
  type = string
}
