/*
  variables.tf - Spoke AI Container App Module Variables

  This file defines all input variables for the AI spoke container app module,
  including app configuration, identity management, and integration settings.
*/

# =============================================================================
# RESOURCE GROUP AND LOCATION
# =============================================================================

variable "spoke_ai_container_app_resource_group_name" {
  description = "The name of the resource group for AI spoke container app resources."
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

variable "spoke_ai_container_app_environment_resource_id" {
  description = "The resource ID of the container apps environment."
  type        = string
}

# Random suffix configuration for container apps
variable "spoke_ai_container_app_random_suffix_length" {
  description = "The length of the random suffix for the container app names."
  type        = number
  default     = 4
}

variable "spoke_ai_container_app_random_suffix_special" {
  description = "Whether to include special characters in the container app random suffix."
  type        = bool
  default     = false
}

variable "spoke_ai_container_app_random_suffix_upper" {
  description = "Whether to include uppercase letters in the container app random suffix."
  type        = bool
  default     = false
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
  description = "Default transport protocol for the container app ingress (http, https, auto)."
  type        = string
  default     = "http"
  validation {
    condition     = contains(["http", "http2", "tcp", "auto"], var.spoke_ai_container_app_ingress_transport)
    error_message = "Transport must be one of: http, http2, tcp, auto."
  }
}

# =============================================================================
# DEFAULT IDENTITY CONFIGURATION
# =============================================================================

variable "spoke_ai_container_app_identity_id" {
  description = "The default ID of the managed identity for the container app."
  type        = string
}

variable "spoke_ai_container_app_identity_lifecycle" {
  description = "The default lifecycle policy for the container app identity."
  type        = string
  default     = "All"
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
# WORKLOAD PROFILE CONFIGURATION
# =============================================================================

variable "spoke_ai_container_apps_workload_profile_max_count" {
  description = "Maximum count for the workload profile."
  type        = number
  default     = 3
}

variable "spoke_ai_container_apps_workload_profile_min_count" {
  description = "Minimum count for the workload profile."
  type        = number
  default     = 0
}

variable "spoke_ai_container_apps_workload_profile_polling_interval" {
  description = "Polling interval for the workload profile."
  type        = number
  default     = 30
}

variable "spoke_ai_container_apps_workload_profile_revision_suffix" {
  description = "Revision suffix for the workload profile."
  type        = string
  default     = ""
}

variable "spoke_ai_container_app_ingress_traffic_weight" {
  description = "Default traffic weight for the container app ingress."
  type        = number
  default     = 100
}


