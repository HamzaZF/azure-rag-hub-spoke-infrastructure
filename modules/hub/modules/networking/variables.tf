/*
  variables.tf (Hub Networking Submodule)

  This file defines all input variables for the Kelix Azure Hub Networking submodule.
*/

# -----------------------------------------------------------------------------
# Networking Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where networking resources will be deployed.
variable "hub_networking_location" {
  description = "The Azure region where networking resources will be deployed."
  type        = string
}

# The name of the resource group where networking resources will be created.
variable "hub_networking_resource_group_name" {
  description = "The name of the resource group where networking resources will be created."
  type        = string
}

# The address space for the hub virtual network.
variable "hub_networking_vnet_address_space" {
  description = "The address space for the hub virtual network."
  type        = list(string)
}

# The address prefix for the private endpoints subnet in the hub networking module.
variable "hub_networking_pe_subnet_prefix" {
  description = "The address prefix for the private endpoints subnet in the hub networking module."
  type        = string
}

# The address prefix for the virtual machine subnet in the hub networking module.
variable "hub_networking_vm_subnet_prefix" {
  description = "The address prefix for the virtual machine subnet in the hub networking module."
  type        = string
}

# Random suffix configuration for NSG PE
variable "hub_networking_nsg_pe_random_suffix_length" {
  description = "The length of the random suffix for the private endpoints NSG name."
  type        = number
  default     = 4
}

variable "hub_networking_nsg_pe_random_suffix_special" {
  description = "Whether to include special characters in the NSG PE random suffix."
  type        = bool
  default     = false
}

variable "hub_networking_nsg_pe_random_suffix_upper" {
  description = "Whether to include uppercase letters in the NSG PE random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for NSG VM
variable "hub_networking_nsg_vm_random_suffix_length" {
  description = "The length of the random suffix for the VM NSG name."
  type        = number
  default     = 4
}

variable "hub_networking_nsg_vm_random_suffix_special" {
  description = "Whether to include special characters in the NSG VM random suffix."
  type        = bool
  default     = false
}

variable "hub_networking_nsg_vm_random_suffix_upper" {
  description = "Whether to include uppercase letters in the NSG VM random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for VNet
variable "hub_networking_vnet_random_suffix_length" {
  description = "The length of the random suffix for the virtual network name."
  type        = number
  default     = 4
}

variable "hub_networking_vnet_random_suffix_special" {
  description = "Whether to include special characters in the VNet random suffix."
  type        = bool
  default     = false
}

variable "hub_networking_vnet_random_suffix_upper" {
  description = "Whether to include uppercase letters in the VNet random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for Subnet PE
variable "hub_networking_subnet_pe_random_suffix_length" {
  description = "The length of the random suffix for the private endpoints subnet name."
  type        = number
  default     = 4
}

variable "hub_networking_subnet_pe_random_suffix_special" {
  description = "Whether to include special characters in the subnet PE random suffix."
  type        = bool
  default     = false
}

variable "hub_networking_subnet_pe_random_suffix_upper" {
  description = "Whether to include uppercase letters in the subnet PE random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for Subnet VM
variable "hub_networking_subnet_vm_random_suffix_length" {
  description = "The length of the random suffix for the VM subnet name."
  type        = number
  default     = 4
}

variable "hub_networking_subnet_vm_random_suffix_special" {
  description = "Whether to include special characters in the subnet VM random suffix."
  type        = bool
  default     = false
}

variable "hub_networking_subnet_vm_random_suffix_upper" {
  description = "Whether to include uppercase letters in the subnet VM random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for Subnet Azure Firewall
variable "hub_networking_subnet_azure_firewall_random_suffix_length" {
  description = "The length of the random suffix for the Azure Firewall subnet name."
  type        = number
  default     = 4
}

variable "hub_networking_subnet_azure_firewall_random_suffix_special" {
  description = "Whether to include special characters in the subnet Azure Firewall random suffix."
  type        = bool
  default     = false
}

variable "hub_networking_subnet_azure_firewall_random_suffix_upper" {
  description = "Whether to include uppercase letters in the subnet Azure Firewall random suffix."
  type        = bool
  default     = false
}

# The address prefix for the Azure Firewall subnet.
variable "hub_networking_azure_firewall_subnet_prefix" {
  description = "The address prefix for the Azure Firewall subnet."
  type        = string
}


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

# variable "log_analytics_workspace_id" {
#   description = "The ID of the Log Analytics Workspace for diagnostics."
#   type        = string
# }

# Allowed sources for SSH access to VMs
variable "hub_allowed_ssh_sources" {
  description = "List of IP addresses or CIDR ranges allowed to access VMs via SSH."
  type        = list(string)
  default     = ["*"]  # Allow all sources by default - should be restricted in production
}

# The address prefix for the API spoke private endpoint subnet.
variable "spoke_api_networking_pe_subnet_prefix" {
  description = "The address prefix (CIDR) for the API spoke private endpoint subnet. Used for outbound NSG rules to allow access from hub VMs to API spoke private endpoints."
  type        = string
}

# The address prefix for the AI spoke private endpoint subnet.
variable "spoke_ai_networking_pe_subnet_prefix" {
  description = "The address prefix (CIDR) for the AI spoke private endpoint subnet. Used for outbound NSG rules to allow access from hub VMs to AI spoke private endpoints."
  type        = string
}

# The address prefix for the AI spoke container apps environment subnet.
variable "spoke_ai_networking_cappenv_subnet_prefix" {
  description = "The address prefix (CIDR) for the AI spoke container apps environment subnet. Used for outbound NSG rules to allow access from hub VMs to AI spoke container apps environment."
  type        = string
}

