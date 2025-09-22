/*
  variables.tf (Spoke API Web App Frontend Submodule)

  This file defines all input variables for the Kelix Azure Spoke API Web App Frontend submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the Frontend Web App resources will be deployed.
variable "spoke_api_frontend_location" {
  description = "The Azure region where the Frontend Web App resources will be deployed."
  type        = string
}

# The name of the resource group where the Frontend Web App resources will be created.
variable "spoke_api_frontend_resource_group_name" {
  description = "The name of the resource group where the Frontend Web App resources will be created."
  type        = string
}

# The SKU name for the spoke API frontend web app (e.g., B1, S1).
variable "spoke_api_frontend_sku_name" {
  description = "The SKU name for the spoke API frontend web app (e.g., B1, S1)."
  type        = string
}

# The subnet ID for the frontend web app virtual network integration.
variable "spoke_api_frontend_subnet_id" {
  description = "The subnet ID for the frontend web app virtual network integration."
  type        = string
}

# Random suffix configuration for frontend service plan
variable "spoke_api_frontend_service_plan_random_suffix_length" {
  description = "The length of the random suffix for the frontend service plan name."
  type        = number
  default     = 4
}

variable "spoke_api_frontend_service_plan_random_suffix_special" {
  description = "Whether to include special characters in the frontend service plan random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_frontend_service_plan_random_suffix_upper" {
  description = "Whether to include uppercase letters in the frontend service plan random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for frontend web app
variable "spoke_api_frontend_web_app_random_suffix_length" {
  description = "The length of the random suffix for the frontend web app name."
  type        = number
  default     = 4
}

variable "spoke_api_frontend_web_app_random_suffix_special" {
  description = "Whether to include special characters in the frontend web app random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_frontend_web_app_random_suffix_upper" {
  description = "Whether to include uppercase letters in the frontend web app random suffix."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Container Configuration
# -----------------------------------------------------------------------------

# The login server for the Azure Container Registry.
variable "acr_login_server" {
  description = "The login server for the Azure Container Registry."
  type        = string
}

# The name of the frontend container image to deploy.
variable "frontend_container_image_name" {
  description = "The name of the frontend container image to deploy."
  type        = string
}

# -----------------------------------------------------------------------------
# Naming Convention
# -----------------------------------------------------------------------------

# Company or organization name for resource naming.
variable "naming_company" {
  description = "Company or organization name for resource naming."
  type        = string
}

# Product or application name for resource naming.
variable "naming_product" {
  description = "Product or application name for resource naming."
  type        = string
}

# Environment name for resource naming (e.g., dev, staging, prod).
variable "naming_environment" {
  description = "Environment name for resource naming (e.g., dev, staging, prod)."
  type        = string
}

# Region name for resource naming.
variable "naming_region" {
  description = "Region name for resource naming."
  type        = string
}

# -----------------------------------------------------------------------------
# Backend API Configuration
# -----------------------------------------------------------------------------

# The backend API URL for the frontend to communicate with.
variable "backend_api_url" {
  description = "The backend API URL for the frontend to communicate with."
  type        = string
}

# The backend API base URL for the frontend.
variable "backend_api_base_url" {
  description = "The backend API base URL for the frontend."
  type        = string
}

# -----------------------------------------------------------------------------
# Frontend Application Configuration
# -----------------------------------------------------------------------------

# The frontend domain URL.
variable "frontend_domain" {
  description = "The frontend domain URL."
  type        = string
}

# Node.js environment for the frontend application.
variable "frontend_node_env" {
  description = "Node.js environment for the frontend application."
  type        = string
  default     = "production"
}

# Port for the frontend application.
variable "frontend_port" {
  description = "Port for the frontend application."
  type        = string
  default     = "3000"
}

# Development environment flag.
variable "is_dev_environment" {
  description = "Flag indicating if this is a development environment."
  type        = string
  default     = "false"
}

# -----------------------------------------------------------------------------
# Application Insights Configuration (Sensitive)
# -----------------------------------------------------------------------------

variable "appinsights_instrumentation_key" {
  description = "Application Insights instrumentation key."
  type        = string
  sensitive   = true
}

variable "appinsights_profiler_version" {
  description = "Application Insights profiler feature version."
  type        = string
  default     = "1.0.0"
}

variable "appinsights_snapshot_version" {
  description = "Application Insights snapshot feature version."
  type        = string
  default     = "1.0.0"
}

variable "applicationinsights_config_content" {
  description = "Application Insights configuration content."
  type        = string
  default     = ""
}

variable "applicationinsights_connection_string" {
  description = "Application Insights connection string."
  type        = string
  sensitive   = true
}

variable "applicationinsights_agent_version" {
  description = "Application Insights agent extension version."
  type        = string
  default     = "~3"
}

# -----------------------------------------------------------------------------
# Extensions Configuration
# -----------------------------------------------------------------------------

variable "diagnostic_services_version" {
  description = "Diagnostic services extension version."
  type        = string
  default     = "~3"
}

variable "docker_enable_ci" {
  description = "Docker continuous integration enable flag."
  type        = string
  default     = "true"
}

# -----------------------------------------------------------------------------
# Application Insights Advanced Configuration
# -----------------------------------------------------------------------------

variable "app_insights_base_extensions" {
  description = "Application Insights base extensions configuration."
  type        = string
  default     = "disabled"
}

variable "app_insights_mode" {
  description = "Application Insights mode configuration."
  type        = string
  default     = "recommended"
}

variable "app_insights_preempt_sdk" {
  description = "Application Insights preempt SDK configuration."
  type        = string
  default     = "disabled"
}
