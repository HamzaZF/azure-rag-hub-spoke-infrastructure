/*
  variables.tf (Hub Private Endpoint - OpenAI)

  This file defines all input variables for the Kelix Azure Hub Private Endpoint (OpenAI) submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the private endpoint will be deployed.
variable "hub_pe_openai_location" {
  description = "The location for the private endpoint."
  type        = string
}

# The name of the resource group where the private endpoint will be created.
variable "hub_pe_openai_resource_group_name" {
  description = "The name of the resource group for the private endpoint."
  type        = string
}

# The ID of the subnet where the private endpoint will be deployed.
variable "hub_pe_openai_subnet_id" {
  description = "The ID of the subnet for the private endpoint."
  type        = string
}

# The ID of the OpenAI cognitive account to connect with the private endpoint.
variable "hub_pe_openai_cognitive_account_id" {
  description = "The ID of the OpenAI cognitive account for the private endpoint."
  type        = string
}

# Random suffix configuration for private endpoint
variable "hub_pe_openai_pe_random_suffix_length" {
  description = "The length of the random suffix for the OpenAI private endpoint name."
  type        = number
  default     = 4
}

variable "hub_pe_openai_pe_random_suffix_special" {
  description = "Whether to include special characters in the OpenAI PE random suffix."
  type        = bool
  default     = false
}

variable "hub_pe_openai_pe_random_suffix_upper" {
  description = "Whether to include uppercase letters in the OpenAI PE random suffix."
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

