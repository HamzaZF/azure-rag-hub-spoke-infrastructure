/*
  variables.tf (Hub OpenAI Submodule)

  This file defines all input variables for the Kelix Azure Hub OpenAI submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the OpenAI resources will be deployed.
variable "hub_openai_location" {
  description = "The Azure region where the OpenAI resources will be deployed."
  type        = string
}

# The name of the resource group where the OpenAI resources will be created.
variable "hub_openai_resource_group_name" {
  description = "The name of the resource group where the OpenAI resources will be created."
  type        = string
}

# OpenAI Configuration
variable "hub_openai_sku_name" {
  description = "The SKU name for the OpenAI cognitive account."
  type        = string
  default     = "S0"
}

variable "hub_openai_gpt4_1_mini_model_name" {
  description = "The model name for GPT-4.1 Mini deployment."
  type        = string
  default     = "gpt-4.1-mini"
}

variable "hub_openai_gpt4_1_mini_model_version" {
  description = "The model version for GPT-4.1 Mini deployment."
  type        = string
  default     = "2025-04-14"
}

variable "hub_openai_gpt4_1_mini_sku_name" {
  description = "The SKU name for GPT-4.1 Mini deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_gpt4_1_mini_sku_tier" {
  description = "The SKU tier for GPT-4.1 Mini deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_gpt4_1_mini_sku_size" {
  description = "The SKU size for GPT-4.1 Mini deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_gpt4_1_mini_capacity" {
  description = "The capacity for GPT-4.1 Mini deployment."
  type        = number
  default     = 1
}

variable "hub_openai_text_embedding_model_name" {
  description = "The model name for text embedding deployment."
  type        = string
  default     = "text-embedding-3-small"
}

variable "hub_openai_text_embedding_model_version" {
  description = "The model version for text embedding deployment."
  type        = string
  default     = "1"
}

variable "hub_openai_text_embedding_sku_name" {
  description = "The SKU name for text embedding deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_text_embedding_sku_tier" {
  description = "The SKU tier for text embedding deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_text_embedding_sku_size" {
  description = "The SKU size for text embedding deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_text_embedding_capacity" {
  description = "The capacity for text embedding deployment."
  type        = number
  default     = 1
}

variable "hub_openai_custom_subdomain_name" {
  description = "The custom subdomain name for the OpenAI cognitive account."
  type        = string
  //default     = "kelix-ai"
}

# Random suffix configuration
variable "hub_openai_random_suffix_length" {
  description = "The length of the random suffix for the OpenAI cognitive account name."
  type        = number
  default     = 4
}

variable "hub_openai_random_suffix_special" {
  description = "Whether to include special characters in the random suffix."
  type        = bool
  default     = false
}

variable "hub_openai_random_suffix_upper" {
  description = "Whether to include uppercase letters in the random suffix."
  type        = bool
  default     = false
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