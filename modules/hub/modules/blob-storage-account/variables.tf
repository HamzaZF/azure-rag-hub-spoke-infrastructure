/*
  variables.tf (Hub Blob Storage Account Submodule)

  This file defines all input variables for the Kelix Azure Hub Blob Storage Account submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the Blob Storage resources will be deployed.
variable "hub_blob_storage_location" {
  description = "The Azure region where the Blob Storage resources will be deployed."
  type        = string
}

# The name of the resource group where the Blob Storage resources will be created.
variable "hub_blob_storage_resource_group_name" {
  description = "The name of the resource group where the Blob Storage resources will be created."
  type        = string
}

# Storage Account Configuration
variable "hub_blob_storage_account_tier" {
  description = "The tier of the blob storage account (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "hub_blob_storage_account_replication_type" {
  description = "The replication type for the blob storage account."
  type        = string
  default     = "GRS"
}

variable "hub_blob_storage_min_tls_version" {
  description = "The minimum TLS version for the blob storage account."
  type        = string
  default     = "TLS1_2"
}

variable "hub_blob_storage_account_kind" {
  description = "The kind of storage account (StorageV2, BlobStorage, etc.)."
  type        = string
  default     = "StorageV2"
}

variable "hub_blob_storage_allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the blob storage account."
  type        = list(string)
  default     = []
}

variable "hub_blob_storage_allowed_ip_rules" {
  description = "List of IP addresses allowed to access the blob storage account."
  type        = list(string)
  default     = []
}

# Random suffix configuration for storage account
variable "hub_blob_storage_random_suffix_length" {
  description = "The length of the random suffix for the storage account name."
  type        = number
  default     = 4
}

variable "hub_blob_storage_random_suffix_special" {
  description = "Whether to include special characters in the random suffix."
  type        = bool
  default     = false
}

variable "hub_blob_storage_random_suffix_upper" {
  description = "Whether to include uppercase letters in the random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for container
variable "hub_blob_storage_container_random_suffix_length" {
  description = "The length of the random suffix for the container name."
  type        = number
  default     = 4
}

variable "hub_blob_storage_container_random_suffix_special" {
  description = "Whether to include special characters in the container random suffix."
  type        = bool
  default     = false
}

variable "hub_blob_storage_container_random_suffix_upper" {
  description = "Whether to include uppercase letters in the container random suffix."
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

# variable "log_analytics_workspace_id" {
#   description = "The ID of the Log Analytics Workspace for diagnostics."
#   type        = string
# }
