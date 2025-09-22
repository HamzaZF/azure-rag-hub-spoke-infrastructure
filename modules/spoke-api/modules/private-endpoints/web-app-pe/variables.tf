/*
  variables.tf (Spoke API Private Endpoint - Web App)

  This file defines all input variables for the Kelix Azure Spoke API Private Endpoint (Web App) submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the private endpoint will be deployed.
variable "spoke_api_pe_web_app_location" {
  description = "The Azure region where the private endpoint will be deployed."
  type        = string
}

# The name of the resource group where the private endpoint will be deployed.
variable "spoke_api_pe_web_app_resource_group_name" {
  description = "The name of the resource group where the private endpoint will be deployed."
  type        = string
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------

# The ID of the virtual network where the private endpoint will be integrated.
variable "spoke_api_pe_web_app_vnet_id" {
  description = "The ID of the virtual network where the private endpoint will be integrated."
  type        = string
}

# The ID of the subnet for private endpoints.
variable "spoke_api_pe_web_app_subnet_id" {
  description = "The ID of the subnet for private endpoints."
  type        = string
}

# -----------------------------------------------------------------------------
# Web App Configuration
# -----------------------------------------------------------------------------

# The ID of the Web App for the private endpoint connection.
variable "spoke_api_pe_web_app_id" {
  description = "The ID of the Web App for the private endpoint connection."
  type        = string
}

# Random suffix configuration for private endpoint
variable "spoke_api_pe_web_app_pe_random_suffix_length" {
  description = "The length of the random suffix for the web app private endpoint name."
  type        = number
  default     = 4
}

variable "spoke_api_pe_web_app_pe_random_suffix_special" {
  description = "Whether to include special characters in the web app PE random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_pe_web_app_pe_random_suffix_upper" {
  description = "Whether to include uppercase letters in the web app PE random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for DNS zone group
variable "spoke_api_pe_web_app_dns_group_random_suffix_length" {
  description = "The length of the random suffix for the web app DNS zone group name."
  type        = number
  default     = 4
}

variable "spoke_api_pe_web_app_dns_group_random_suffix_special" {
  description = "Whether to include special characters in the web app DNS group random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_pe_web_app_dns_group_random_suffix_upper" {
  description = "Whether to include uppercase letters in the web app DNS group random suffix."
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

