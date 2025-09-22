/*
  variables.tf - Spoke AI Networking Module Variables

  This file defines all input variables for the AI spoke networking module,
  including resource configuration, naming conventions, and cross-module
  dependencies.
*/

# =============================================================================
# RESOURCE GROUP AND LOCATION
# =============================================================================

variable "spoke_ai_networking_resource_group_name" {
  description = "The name of the resource group for AI spoke networking resources."
  type        = string
}

variable "spoke_ai_networking_location" {
  description = "The Azure region for AI spoke networking resources."
  type        = string
}

# =============================================================================
# VIRTUAL NETWORK CONFIGURATION
# =============================================================================

variable "spoke_ai_networking_vnet_address_space" {
  description = "The address space for the AI spoke virtual network."
  type        = list(string)
}

# Random suffix configuration for VNet
variable "spoke_ai_networking_vnet_random_suffix_length" {
  description = "The length of the random suffix for the VNet name."
  type        = number
  default     = 4
}

variable "spoke_ai_networking_vnet_random_suffix_special" {
  description = "Whether to include special characters in the VNet random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_networking_vnet_random_suffix_upper" {
  description = "Whether to include uppercase letters in the VNet random suffix."
  type        = bool
  default     = false
}

# =============================================================================
# SUBNET CONFIGURATION
# =============================================================================

variable "spoke_ai_networking_pe_subnet_prefix" {
  description = "The address prefix for the private endpoints subnet in the AI spoke."
  type        = string
}

variable "spoke_ai_networking_cappenv_subnet_prefix" {
  description = "The address prefix for the container apps environment subnet in the AI spoke."
  type        = string
}

# =============================================================================
# NETWORK SECURITY GROUPS
# =============================================================================

# Random suffix configuration for NSG PE
variable "spoke_ai_networking_nsg_pe_random_suffix_length" {
  description = "The length of the random suffix for the PE NSG name."
  type        = number
  default     = 4
}

variable "spoke_ai_networking_nsg_pe_random_suffix_special" {
  description = "Whether to include special characters in the NSG PE random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_networking_nsg_pe_random_suffix_upper" {
  description = "Whether to include uppercase letters in the NSG PE random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for NSG Container Apps Environment
variable "spoke_ai_networking_nsg_cappenv_random_suffix_length" {
  description = "The length of the random suffix for the container apps environment NSG name."
  type        = number
  default     = 4
}

variable "spoke_ai_networking_nsg_cappenv_random_suffix_special" {
  description = "Whether to include special characters in the NSG cappenv random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_networking_nsg_cappenv_random_suffix_upper" {
  description = "Whether to include uppercase letters in the NSG cappenv random suffix."
  type        = bool
  default     = false
}

# =============================================================================
# VIRTUAL NETWORK PEERING
# =============================================================================

# Random suffix configuration for AI to Hub peering
variable "spoke_ai_networking_peering_ai_to_hub_random_suffix_length" {
  description = "The length of the random suffix for the AI to hub peering name."
  type        = number
  default     = 4
}

variable "spoke_ai_networking_peering_ai_to_hub_random_suffix_special" {
  description = "Whether to include special characters in the AI to hub peering random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_networking_peering_ai_to_hub_random_suffix_upper" {
  description = "Whether to include uppercase letters in the AI to hub peering random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for Hub to AI peering
variable "spoke_ai_networking_peering_hub_to_ai_random_suffix_length" {
  description = "The length of the random suffix for the hub to AI peering name."
  type        = number
  default     = 4
}

variable "spoke_ai_networking_peering_hub_to_ai_random_suffix_special" {
  description = "Whether to include special characters in the hub to AI peering random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_networking_peering_hub_to_ai_random_suffix_upper" {
  description = "Whether to include uppercase letters in the hub to AI peering random suffix."
  type        = bool
  default     = false
}

# =============================================================================
# HUB NETWORKING INTEGRATION
# =============================================================================

variable "hub_vnet_id" {
  description = "The ID of the hub virtual network for peering configuration."
  type        = string
}

variable "hub_vnet_name" {
  description = "The name of the hub virtual network for peering configuration."
  type        = string
}

variable "hub_resource_group_name" {
  description = "The name of the hub resource group for peering configuration."
  type        = string
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

# =============================================================================
# CROSS-SPOKE NETWORKING INTEGRATION
# =============================================================================

variable "spoke_api_vnet_address_space" {
  description = "The address space for the API spoke virtual network for security rules."
  type        = list(string)
}

variable "spoke_ai_pe_subnet_prefix" {
  description = "The address prefix for the private endpoints subnet in the AI spoke for security rules."
  type        = string
}

variable "hub_vnet_address_space" {
  description = "The address space for the hub virtual network for security rules."
  type        = list(string)
}


# =============================================================================

variable "spoke_ai_networking_route_table_random_suffix_length" {
  description = "The length of the random suffix for the route table name."
  type        = number
  default     = 4
}

variable "spoke_ai_networking_route_table_random_suffix_special" {
  description = "Whether to include special characters in the route table random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_networking_route_table_random_suffix_upper" {
  description = "Whether to include uppercase letters in the route table random suffix."
  type        = bool
  default     = false
}

variable "hub_azure_firewall_public_ip_address" {
  description = "The public IP address of the Azure Firewall."
  type        = string
}