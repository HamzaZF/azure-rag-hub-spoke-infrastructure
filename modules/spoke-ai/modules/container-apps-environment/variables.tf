/*
  variables.tf - Spoke AI Container Apps Environment Module Variables

  This file defines all input variables for the AI spoke container apps environment module,
  including environment configuration, networking integration, and workload profile settings.
*/

# =============================================================================
# RESOURCE GROUP AND LOCATION
# =============================================================================

variable "spoke_ai_container_apps_resource_group_name" {
  description = "The name of the resource group for AI spoke container apps environment resources."
  type        = string
}

variable "spoke_ai_container_apps_location" {
  description = "The Azure region for AI spoke container apps environment resources."
  type        = string
}

# =============================================================================
# INFRASTRUCTURE CONFIGURATION
# =============================================================================

variable "spoke_ai_container_apps_infrastructure_rg_name" {
  description = "The name of the infrastructure resource group for the container apps environment."
  type        = string
}

variable "spoke_ai_container_apps_infrastructure_subnet_id" {
  description = "The ID of the infrastructure subnet for the container apps environment."
  type        = string
}

# =============================================================================
# ENVIRONMENT CONFIGURATION
# =============================================================================

variable "spoke_ai_container_apps_zone_redundancy_enabled" {
  description = "Whether to enable zone redundancy for the container apps environment."
  type        = bool
  default     = false
}

variable "spoke_ai_container_apps_mutual_tls_enabled" {
  description = "Whether to enable mutual TLS for the container apps environment."
  type        = bool
  default     = false
}

# Random suffix configuration for container apps environment
variable "spoke_ai_container_apps_environment_random_suffix_length" {
  description = "The length of the random suffix for the container apps environment name."
  type        = number
  default     = 4
}

variable "spoke_ai_container_apps_environment_random_suffix_special" {
  description = "Whether to include special characters in the container apps environment random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_container_apps_environment_random_suffix_upper" {
  description = "Whether to include uppercase letters in the container apps environment random suffix."
  type        = bool
  default     = false
}

# =============================================================================
# WORKLOAD PROFILE CONFIGURATION
# =============================================================================

variable "spoke_ai_container_apps_workload_profile_name" {
  description = "The name of the workload profile for the container apps environment."
  type        = string
  default     = "Consumption"
}

variable "spoke_ai_container_apps_workload_profile_type" {
  description = "The type of the workload profile for the container apps environment."
  type        = string
  default     = "Consumption"
}

variable "spoke_ai_container_apps_workload_profile_min_count" {
  description = "The minimum count for the workload profile."
  type        = number
  default     = 0
}

variable "spoke_ai_container_apps_workload_profile_max_count" {
  description = "The maximum count for the workload profile."
  type        = number
  default     = 3
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