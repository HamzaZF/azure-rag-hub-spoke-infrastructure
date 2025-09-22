/*
  variables.tf (Hub PostgreSQL Flexible Server Submodule)

  This file defines all input variables for the Kelix Azure Hub PostgreSQL Flexible Server submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the PostgreSQL Flexible Server will be deployed.
variable "hub_postgresql_location" {
  description = "The Azure region where the PostgreSQL Flexible Server will be deployed."
  type        = string
}

# The name of the resource group where the PostgreSQL Flexible Server will be created.
variable "hub_postgresql_resource_group_name" {
  description = "The name of the resource group where the PostgreSQL Flexible Server will be created."
  type        = string
}

# The administrator login for the PostgreSQL Flexible Server.
variable "hub_postgresql_administrator_login" {
  description = "The administrator login for the PostgreSQL Flexible Server."
  type        = string
}

# The administrator password for the PostgreSQL Flexible Server.
variable "hub_postgresql_administrator_password" {
  description = "The administrator password for the PostgreSQL Flexible Server."
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Storage
# -----------------------------------------------------------------------------

# The storage size in MB for the PostgreSQL Flexible Server.
variable "hub_postgresql_storage_mb" {
  description = "The storage size in MB for the PostgreSQL Flexible Server."
  type        = number
}

# The storage tier for the PostgreSQL Flexible Server.
variable "hub_postgresql_storage_tier" {
  description = "The storage tier for the PostgreSQL Flexible Server."
  type        = string
}

# -----------------------------------------------------------------------------
# SKU
# -----------------------------------------------------------------------------

# The SKU name for the PostgreSQL Flexible Server.
variable "hub_postgresql_sku_name" {
  description = "The SKU name for the PostgreSQL Flexible Server."
  type        = string
}

# PostgreSQL Configuration
variable "hub_postgresql_version" {
  description = "The PostgreSQL version for the flexible server."
  type        = string
  default     = "12"
}

variable "hub_postgresql_zone" {
  description = "The availability zone for the PostgreSQL flexible server."
  type        = string
  default     = "1"
}

variable "hub_postgresql_active_directory_auth_enabled" {
  description = "Whether to enable Active Directory authentication for PostgreSQL."
  type        = bool
  default     = true
}

variable "hub_postgresql_password_auth_enabled" {
  description = "Whether to enable password authentication for PostgreSQL."
  type        = bool
  default     = false
}

# Random suffix configuration
variable "hub_postgresql_random_suffix_length" {
  description = "The length of the random suffix for the PostgreSQL server name."
  type        = number
  default     = 4
}

variable "hub_postgresql_random_suffix_special" {
  description = "Whether to include special characters in the random suffix."
  type        = bool
  default     = false
}

variable "hub_postgresql_random_suffix_upper" {
  description = "Whether to include uppercase letters in the random suffix."
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

# variable "log_analytics_workspace_id" {
#   description = "The ID of the Log Analytics Workspace for diagnostics."
#   type        = string
# }

# -----------------------------------------------------------------------------
# Databricks Identity Variables
# -----------------------------------------------------------------------------

# # The principal ID of the Databricks managed identity (from access connector)
# variable "databricks_managed_identity_principal_id" {
#   description = "The principal ID of the Databricks managed identity to be used as PostgreSQL Azure AD administrator."
#   type        = string
# }

# # The principal name of the Databricks managed identity (from access connector)
# variable "databricks_managed_identity_principal_name" {
#   description = "The principal name of the Databricks managed identity to be used as PostgreSQL Azure AD administrator."
#   type        = string
# }

# -----------------------------------------------------------------------------
# VM Identity Variables
# -----------------------------------------------------------------------------

# The principal ID of the VM managed identity
variable "vm_managed_identity_principal_id" {
  description = "The principal ID of the VM managed identity to be used as PostgreSQL Azure AD administrator."
  type        = string
}

# The principal name of the VM managed identity
variable "vm_managed_identity_principal_name" {
  description = "The principal name of the VM managed identity to be used as PostgreSQL Azure AD administrator."
  type        = string
}