/*
  variables.tf (Hub Azure Firewall Submodule)

  This file defines all input variables for the Kelix Azure Hub Azure Firewall submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the Azure Firewall will be deployed.
variable "hub_azure_firewall_location" {
  description = "The Azure region where the Azure Firewall will be deployed."
  type        = string
}

# The name of the resource group where the Azure Firewall will be created.
variable "hub_azure_firewall_resource_group_name" {
  description = "The name of the resource group where the Azure Firewall will be created."
  type        = string
}

# The SKU tier for the Azure Firewall.
variable "hub_azure_firewall_sku_tier" {
  description = "The SKU tier for the Azure Firewall (e.g., Standard, Premium)."
  type        = string
}

# The SKU name for the Azure Firewall.
variable "hub_azure_firewall_sku_name" {
  description = "The SKU name for the Azure Firewall (e.g., AZFW_VNet, AZFW_Hub)."
  type        = string
}

# The subnet ID where the Azure Firewall will be deployed.
variable "hub_azure_firewall_subnet_id" {
  description = "The subnet ID where the Azure Firewall will be deployed."
  type        = string
}

# -----------------------------------------------------------------------------
# Random Suffix Configuration
# -----------------------------------------------------------------------------

# Random suffix configuration
variable "hub_azure_firewall_random_suffix_length" {
  description = "The length of the random suffix for the Azure Firewall resources."
  type        = number
  default     = 4
}

variable "hub_azure_firewall_random_suffix_special" {
  description = "Whether to include special characters in the random suffix."
  type        = bool
  default     = false
}

variable "hub_azure_firewall_random_suffix_upper" {
  description = "Whether to include uppercase letters in the random suffix."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Naming Convention
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------

variable "spoke_api_vnet_address_space" {
  description = "The address space of the spoke API VNet."
  type        = list(string)
}

variable "spoke_ai_vnet_address_space" {
  description = "The address space of the spoke AI VNet."
  type        = list(string)
}

variable "hub_azure_firewall_name" {
  description = "The name of the Azure Firewall."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Azure Firewall will be created."
  type        = string
}