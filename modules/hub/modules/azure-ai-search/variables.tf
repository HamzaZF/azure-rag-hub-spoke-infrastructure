/*
  variables.tf (Hub Azure AI Search Submodule)

  This file defines all input variables for the Kelix Azure Hub AI Search submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the AI Search resources will be deployed.
variable "hub_ai_search_location" {
  description = "The Azure region where the AI Search resources will be deployed."
  type        = string
}

# The name of the resource group where the AI Search resources will be created.
variable "hub_ai_search_resource_group_name" {
  description = "The name of the resource group where the AI Search resources will be created."
  type        = string
}

# The SKU for the Azure AI Search service (e.g., Basic, Standard, StorageOptimized).
variable "hub_ai_search_sku" {
  description = "The SKU for the Azure AI Search service (e.g., Basic, Standard, StorageOptimized)."
  type        = string
}

# Azure AI Search Configuration
variable "hub_ai_search_hosting_mode" {
  description = "The hosting mode for the Azure AI Search service."
  type        = string
  default     = "Default"
}

variable "hub_ai_search_partition_count" {
  description = "The number of partitions for the Azure AI Search service."
  type        = string
  default     = "1"
}

variable "hub_ai_search_replica_count" {
  description = "The number of replicas for the Azure AI Search service."
  type        = string
  default     = "1"
}

variable "hub_ai_search_semantic_search_sku" {
  description = "The semantic search SKU for the Azure AI Search service."
  type        = string
  default     = "free"
}

# Random suffix configuration
variable "hub_ai_search_random_suffix_length" {
  description = "The length of the random suffix for the AI Search service name."
  type        = number
  default     = 4
}

variable "hub_ai_search_random_suffix_special" {
  description = "Whether to include special characters in the random suffix."
  type        = bool
  default     = false
}

variable "hub_ai_search_random_suffix_upper" {
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
