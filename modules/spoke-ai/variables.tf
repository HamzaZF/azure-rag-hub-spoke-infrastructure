/*
  variables.tf - Spoke AI Module Variables

  This file defines all input variables for the AI spoke module, including
  resource configuration, networking settings, storage options, and cross-module
  dependencies.
*/

# =============================================================================
# KEY VAULT CONFIGURATION
# =============================================================================

variable "spoke_ai_key_vault_sku_name" {
  description = "The SKU name for the key vault."
  type        = string
}

variable "spoke_ai_key_vault_random_suffix_length" {
  description = "The length of the random suffix for the key vault."
  type        = number
}

variable "spoke_ai_key_vault_random_suffix_special" {
  description = "The special characters for the key vault random suffix."
  type        = string
}

variable "spoke_ai_key_vault_random_suffix_upper" {
  description = "The uppercase characters for the key vault random suffix."
  type        = string
}

# =============================================================================
# RESOURCE GROUP AND LOCATION
# =============================================================================

variable "spoke_ai_location" {
  description = "The Azure region for AI spoke resources."
  type        = string
}

variable "spoke_ai_container_apps_resource_group_name" {
  description = "The name of the resource group for AI spoke resources."
  type        = string
}

variable "spoke_ai_container_apps_infrastructure_rg_name" {
  description = "The name of the resource group for AI spoke container apps resources."
  type        = string
}

# =============================================================================
# NETWORKING CONFIGURATION
# =============================================================================

variable "spoke_ai_vnet_address_space" {
  description = "The address space for the AI spoke virtual network."
  type        = list(string)
}

variable "spoke_ai_pe_subnet_prefix" {
  description = "The address prefix for the private endpoints subnet in the AI spoke."
  type        = string
}

variable "spoke_ai_cappenv_subnet_prefix" {
  description = "The address prefix for the container apps environment subnet in the AI spoke."
  type        = string
}

# =============================================================================
# HUB NETWORKING INTEGRATION
# =============================================================================

variable "hub_vnet_id" {
  description = "The ID of the hub virtual network for peering configuration."
  type        = string
}

variable "hub_vnet_name" {
  description = "The name of the hub virtual network for peering configuration."
  type        = string
}

variable "hub_resource_group_name" {
  description = "The name of the hub resource group for peering configuration."
  type        = string
}

variable "hub_vnet_address_space" {
  description = "The address space for the hub virtual network for security rules."
  type        = list(string)
}

variable "spoke_api_vnet_address_space" {
  description = "The address space for the API spoke virtual network for security rules."
  type        = list(string)
}

variable "spoke_api_vnet_id" {
  description = "The ID of the API spoke virtual network for DNS zone linking."
  type        = string
}

# =============================================================================
# STORAGE ACCOUNT CONFIGURATION
# =============================================================================

variable "spoke_ai_storage_account_tier" {
  description = "The tier of the storage account (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "spoke_ai_storage_account_replication_type" {
  description = "The replication type for the storage account."
  type        = string
  default     = "LRS"
}

variable "spoke_ai_storage_account_kind" {
  description = "The kind of storage account (StorageV2, BlobStorage, FileStorage, etc.)."
  type        = string
  default     = "StorageV2"
}

variable "spoke_ai_storage_allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the AI storage account."
  type        = list(string)
  default     = []
}

variable "spoke_ai_storage_allowed_ip_rules" {
  description = "List of allowed IP addresses for storage account access."
  type        = list(string)
  default     = []
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

# =============================================================================
# CONTAINER APPS CONFIGURATION
# =============================================================================

variable "spoke_ai_container_apps" {
  description = "Map of container app configurations. Each key represents a unique container app."
  type = map(object({
    name = optional(string, null)
    containers = optional(list(object({
      args = optional(list(string))
      command = optional(list(string))
      cpu = number
      image = string
      memory = string
      name = string
      env = optional(list(object({
        name = string
        secret_name = optional(string)
        value = optional(string)
      })))
    })), null)
    template = optional(object({
      cooldown_period = optional(number, 300)
      max_replicas = optional(number, 10)
      min_replicas = optional(number)
      polling_interval = optional(number, 30)
      revision_suffix = optional(string)
      termination_grace_period_seconds = optional(number)
    }), null)
    identity_settings = optional(list(object({
      identity = string
      lifecycle = string
    })), null)
    ingress = optional(object({
      allow_insecure_connections = bool
      exposed_port = optional(number)
      external_enabled = bool
      target_port = number
      transport = string
      traffic_weight = list(object({
        percentage = number
        latest_revision = bool
      }))
    }), null)
    tags = optional(map(string), null)
  }))
  default = {}
}





variable "spoke_ai_container_app_identity_id" {
  description = "The ID of the managed identity for the container app."
  type        = string
}

variable "spoke_ai_container_app_identity_lifecycle" {
  description = "The default lifecycle policy for the container app identity."
  type        = string
  default     = "All"
}

# =============================================================================
# DEFAULT INGRESS CONFIGURATION
# =============================================================================

variable "spoke_ai_container_app_ingress_allow_insecure_connections" {
  description = "Default setting for whether to allow insecure connections for the container app ingress."
  type        = bool
  default     = false
}

variable "spoke_ai_container_app_ingress_exposed_port" {
  description = "Default exposed port for the container app ingress."
  type        = number
  default     = 80
}

variable "spoke_ai_container_app_ingress_external_enabled" {
  description = "Default setting for whether external access is enabled for the container app ingress."
  type        = bool
  default     = false
}

variable "spoke_ai_container_app_ingress_target_port" {
  description = "Default target port for the container app ingress."
  type        = number
  default     = 80
}

variable "spoke_ai_container_app_ingress_transport" {
  description = "Default transport protocol for the container app ingress (http, http2, tcp, auto)."
  type        = string
  default     = "http"
  validation {
    condition     = contains(["http", "http2", "tcp", "auto"], var.spoke_ai_container_app_ingress_transport)
    error_message = "Transport must be one of: http, http2, tcp, auto."
  }
}

variable "spoke_ai_container_app_ingress_traffic_weight" {
  description = "Default traffic weight for the container app ingress."
  type        = number
  default     = 100
}

# =============================================================================
# CONTAINER APPS ENVIRONMENT CONFIGURATION
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


# ACR Configuration
variable "acr_webhook_scope" {
  description = "The scope for the ACR webhook (e.g., image:tag)."
  type        = string
  default     = "backend-app:*"
}

variable "acr_webhook_status" {
  description = "The status of the ACR webhook (enabled or disabled)."
  type        = string
  default     = "enabled"
}

variable "spoke_ai_networking_route_table_random_suffix_length" {
  description = "The length of the random suffix for the route table name."
  type        = number
  default     = 4
}

variable "spoke_ai_networking_route_table_random_suffix_special" {
  description = "Whether to include special characters in the route table random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_networking_route_table_random_suffix_upper" {
  description = "Whether to include uppercase letters in the route table random suffix."
  type        = bool
  default     = false
}

variable "hub_azure_firewall_public_ip_address" {
  description = "The public IP address of the Azure Firewall."
  type        = string
}
