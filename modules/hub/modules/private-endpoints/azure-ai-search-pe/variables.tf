/*
  variables.tf (Hub Private Endpoint - Azure AI Search)

  This file defines all input variables for the Kelix Azure Hub Private Endpoint (Azure AI Search) submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the private endpoint will be deployed.
variable "hub_pe_ai_search_location" {
  description = "The location for the private endpoint."
  type        = string
}

# The name of the resource group where the private endpoint will be created.
variable "hub_pe_ai_search_resource_group_name" {
  description = "The name of the resource group for the private endpoint."
  type        = string
}

# The ID of the subnet where the private endpoint will be deployed.
variable "hub_pe_ai_search_subnet_id" {
  description = "The ID of the subnet for the private endpoint."
  type        = string
}

# The ID of the AI Search service to connect with the private endpoint.
variable "hub_pe_ai_search_service_id" {
  description = "The ID of the AI search service for the private endpoint."
  type        = string
}

# Random suffix configuration for private endpoint
variable "hub_pe_ai_search_pe_random_suffix_length" {
  description = "The length of the random suffix for the AI Search private endpoint name."
  type        = number
  default     = 4
}

variable "hub_pe_ai_search_pe_random_suffix_special" {
  description = "Whether to include special characters in the AI Search PE random suffix."
  type        = bool
  default     = false
}

variable "hub_pe_ai_search_pe_random_suffix_upper" {
  description = "Whether to include uppercase letters in the AI Search PE random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for private service connection
variable "hub_pe_ai_search_psc_random_suffix_length" {
  description = "The length of the random suffix for the AI Search private service connection name."
  type        = number
  default     = 4
}

variable "hub_pe_ai_search_psc_random_suffix_special" {
  description = "Whether to include special characters in the AI Search PSC random suffix."
  type        = bool
  default     = false
}

variable "hub_pe_ai_search_psc_random_suffix_upper" {
  description = "Whether to include uppercase letters in the AI Search PSC random suffix."
  type        = bool
  default     = false
}

variable "naming_company" {
  description = "Company name for naming convention"
  type        = string
}

variable "naming_product" {
  description = "Product name for naming convention"
  type        = string
}

variable "naming_environment" {
  description = "Environment name for naming convention"
  type        = string
}

variable "naming_region" {
  description = "Region for naming convention"
  type        = string
}