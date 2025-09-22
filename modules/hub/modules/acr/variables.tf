/*
  variables.tf (Hub ACR Submodule)

  This file defines all input variables for the Kelix Azure Hub Azure Container Registry (ACR) submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the ACR will be deployed.
variable "hub_acr_location" {
  description = "The Azure region where the ACR will be deployed."
  type        = string
}

# The name of the resource group where the ACR will be deployed.
variable "hub_acr_resource_group_name" {
  description = "The name of the resource group where the ACR will be deployed."
  type        = string
}

# The SKU for the Azure Container Registry.
variable "hub_acr_sku" {
  description = "The SKU for the Azure Container Registry."
  type        = string
}

# ACR Configuration
variable "hub_acr_admin_enabled" {
  description = "Whether to enable admin access for the Azure Container Registry."
  type        = bool
  default     = false
}

variable "hub_acr_public_network_access_enabled" {
  description = "Whether to enable public network access for the Azure Container Registry."
  type        = bool
  default     = false
}

variable "hub_acr_random_suffix_length" {
  description = "The length of the random suffix for the ACR name."
  type        = number
  default     = 4
}

variable "hub_acr_random_suffix_special" {
  description = "Whether to include special characters in the random suffix."
  type        = bool
  default     = false
}

variable "hub_acr_random_suffix_upper" {
  description = "Whether to include uppercase letters in the random suffix."
  type        = bool
  default     = false
}

# Naming Convention
variable "naming_company" {
  description = "Company or organization name for resource naming."
  type        = string
}

variable "naming_product" {
  description = "Product or application name for resource naming."
  type        = string
}

variable "naming_environment" {
  description = "Deployment environment (e.g., dev, staging, prod) for resource naming."
  type        = string
}

variable "naming_region" {
  description = "Azure region for resource naming."
  type        = string
}