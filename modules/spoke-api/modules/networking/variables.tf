/*
  variables.tf (Spoke API Networking Submodule)

  This file defines all input variables for the Kelix Azure Spoke API Networking submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where API spoke networking resources will be deployed.
variable "spoke_api_networking_location" {
  description = "The Azure region where API spoke networking resources will be deployed."
  type        = string
}

# The name of the resource group where API spoke networking resources will be created.
variable "spoke_api_networking_resource_group_name" {
  description = "The name of the resource group where API spoke networking resources will be created."
  type        = string
}

# The address space for the API spoke virtual network.
variable "spoke_api_networking_vnet_address_space" {
  description = "The address space for the API spoke virtual network."
  type        = list(string)
}

# Random suffix configuration for VNet
variable "spoke_api_networking_vnet_random_suffix_length" {
  description = "The length of the random suffix for the VNet name."
  type        = number
  default     = 4
}

variable "spoke_api_networking_vnet_random_suffix_special" {
  description = "Whether to include special characters in the VNet random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_networking_vnet_random_suffix_upper" {
  description = "Whether to include uppercase letters in the VNet random suffix."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Subnet Configuration
# -----------------------------------------------------------------------------

# The address prefix for the Application Gateway subnet in the API spoke networking module.
variable "spoke_api_networking_ag_subnet_prefix" {
  description = "The address prefix for the Application Gateway subnet in the API spoke networking module."
  type        = string
}

# The address prefix for the private endpoints subnet in the API spoke networking module.
variable "spoke_api_networking_pe_subnet_prefix" {
  description = "The address prefix for the private endpoints subnet in the API spoke networking module."
  type        = string
}

# The address prefix for the web application subnet in the API spoke networking module.
variable "spoke_api_networking_wa_subnet_prefix" {
  description = "The address prefix for the web application subnet in the API spoke networking module."
  type        = string
}

# Random suffix configuration for Application Gateway subnet
variable "spoke_api_networking_subnet_ag_random_suffix_length" {
  description = "The length of the random suffix for the Application Gateway subnet name."
  type        = number
  default     = 4
}

variable "spoke_api_networking_subnet_ag_random_suffix_special" {
  description = "Whether to include special characters in the subnet AG random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_networking_subnet_ag_random_suffix_upper" {
  description = "Whether to include uppercase letters in the subnet AG random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for Private Endpoints subnet
variable "spoke_api_networking_subnet_pe_random_suffix_length" {
  description = "The length of the random suffix for the private endpoints subnet name."
  type        = number
  default     = 4
}

variable "spoke_api_networking_subnet_pe_random_suffix_special" {
  description = "Whether to include special characters in the subnet PE random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_networking_subnet_pe_random_suffix_upper" {
  description = "Whether to include uppercase letters in the subnet PE random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for Web App subnet
variable "spoke_api_networking_subnet_wa_random_suffix_length" {
  description = "The length of the random suffix for the web app subnet name."
  type        = number
  default     = 4
}

variable "spoke_api_networking_subnet_wa_random_suffix_special" {
  description = "Whether to include special characters in the subnet WA random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_networking_subnet_wa_random_suffix_upper" {
  description = "Whether to include uppercase letters in the subnet WA random suffix."
  type        = bool
  default     = false
}

# The address prefix for the hub private endpoints subnet to allow cross-VNet access.
variable "hub_networking_pe_subnet_prefix" {
  description = "The address prefix for the hub private endpoints subnet to allow cross-VNet access."
  type        = string
}

# List of IP addresses allowed to access the Application Gateway (Static Web App outbound IPs)
variable "static_web_app_allowed_ips" {
  description = "List of IP addresses allowed to access the Application Gateway (Static Web App outbound IPs)."
  type        = list(string)
}

# -----------------------------------------------------------------------------
# Network Security Groups
# -----------------------------------------------------------------------------

# Random suffix configuration for NSG Application Gateway
variable "spoke_api_networking_nsg_ag_random_suffix_length" {
  description = "The length of the random suffix for the Application Gateway NSG name."
  type        = number
  default     = 4
}

variable "spoke_api_networking_nsg_ag_random_suffix_special" {
  description = "Whether to include special characters in the NSG AG random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_networking_nsg_ag_random_suffix_upper" {
  description = "Whether to include uppercase letters in the NSG AG random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for NSG Private Endpoints
variable "spoke_api_networking_nsg_pe_random_suffix_length" {
  description = "The length of the random suffix for the private endpoints NSG name."
  type        = number
  default     = 4
}

variable "spoke_api_networking_nsg_pe_random_suffix_special" {
  description = "Whether to include special characters in the NSG PE random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_networking_nsg_pe_random_suffix_upper" {
  description = "Whether to include uppercase letters in the NSG PE random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for NSG Web App
variable "spoke_api_networking_nsg_wa_random_suffix_length" {
  description = "The length of the random suffix for the web app NSG name."
  type        = number
  default     = 4
}

variable "spoke_api_networking_nsg_wa_random_suffix_special" {
  description = "Whether to include special characters in the NSG WA random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_networking_nsg_wa_random_suffix_upper" {
  description = "Whether to include uppercase letters in the NSG WA random suffix."
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

# =============================================================================
# CROSS-SPOKE NETWORKING INTEGRATION
# =============================================================================

variable "spoke_ai_vnet_address_space" {
  description = "The address space for the AI spoke virtual network for security rules."
  type        = list(string)
}

# -----------------------------------------------------------------------------
# Resource Names and Naming Configuration (Legacy)
# -----------------------------------------------------------------------------

variable "spoke_api_networking_nsg_ag_name" {
  description = "The name for the Application Gateway Network Security Group."
  type        = string
  default     = "api-nsg-ag"
}

variable "spoke_api_networking_nsg_pe_name" {
  description = "The name for the Private Endpoints Network Security Group."
  type        = string
  default     = "api-nsg-pe"
}

variable "spoke_api_networking_nsg_wa_name" {
  description = "The name for the Web App Network Security Group."
  type        = string
  default     = "api-nsg-wa"
}

variable "spoke_api_networking_nsg_vm_name" {
  description = "The name for the VM Network Security Group."
  type        = string
  default     = "api-nsg-vm"
}

variable "spoke_api_networking_vnet_name" {
  description = "The name for the API Virtual Network."
  type        = string
  default     = "api-vnet"
}

variable "spoke_api_networking_subnet_ag_name" {
  description = "The name for the Application Gateway subnet."
  type        = string
  default     = "api-subnet-ag"
}

variable "spoke_api_networking_subnet_pe_name" {
  description = "The name for the Private Endpoints subnet."
  type        = string
  default     = "api-subnet-pe"
}

variable "spoke_api_networking_subnet_wa_name" {
  description = "The name for the Web App subnet."
  type        = string
  default     = "api-subnet-wa"
}

variable "spoke_api_networking_subnet_vm_name" {
  description = "The name for the VM subnet."
  type        = string
  default     = "api-subnet-vm"
}


# -----------------------------------------------------------------------------
# Route Table Configuration
# -----------------------------------------------------------------------------

variable "spoke_api_networking_route_table_random_suffix_length" {
  description = "The length of the random suffix for the route table name."
  type        = number
  default     = 4
}

variable "spoke_api_networking_route_table_random_suffix_special" {
  description = "Whether to include special characters in the route table random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_networking_route_table_random_suffix_upper" {
  description = "Whether to include uppercase letters in the route table random suffix."
  type        = bool
  default     = false
}

variable "hub_azure_firewall_public_ip_address" {
  description = "The public IP address of the Azure Firewall."
  type        = string
}
