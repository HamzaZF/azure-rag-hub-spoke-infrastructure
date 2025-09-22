/*
  outputs.tf - Spoke AI Container Apps Environment Module Outputs

  This file defines all output values for the AI spoke container apps environment module,
  providing access to environment details, networking information, and configuration
  for integration with other modules.
*/

# =============================================================================
# CONTAINER APPS ENVIRONMENT OUTPUTS
# =============================================================================

output "spoke_ai_container_apps_environment_id" {
  description = "The ID of the container apps environment."
  value       = azurerm_container_app_environment.capp_env.id
}

output "spoke_ai_container_apps_environment_name" {
  description = "The name of the container apps environment."
  value       = azurerm_container_app_environment.capp_env.name
}

output "spoke_ai_container_apps_environment_location" {
  description = "The location of the container apps environment."
  value       = azurerm_container_app_environment.capp_env.location
}

output "spoke_ai_container_apps_environment_resource_group_name" {
  description = "The resource group name of the container apps environment."
  value       = azurerm_container_app_environment.capp_env.resource_group_name
}

# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================

output "spoke_ai_container_apps_environment_infrastructure_subnet_id" {
  description = "The infrastructure subnet ID used by the container apps environment."
  value       = azurerm_container_app_environment.capp_env.infrastructure_subnet_id
}

output "spoke_ai_container_apps_environment_infrastructure_resource_group_name" {
  description = "The infrastructure resource group name used by the container apps environment."
  value       = azurerm_container_app_environment.capp_env.infrastructure_resource_group_name
}

output "spoke_ai_container_apps_environment_static_ip_address" {
  description = "The static IP address of the container apps environment (when internal load balancer is enabled)."
  value       = azurerm_container_app_environment.capp_env.static_ip_address
}

output "spoke_ai_container_apps_environment_default_domain" {
  description = "The default domain of the container apps environment."
  value       = azurerm_container_app_environment.capp_env.default_domain
}

# =============================================================================
# CONFIGURATION OUTPUTS
# =============================================================================

output "spoke_ai_container_apps_environment_internal_load_balancer_enabled" {
  description = "Whether internal load balancer is enabled for the container apps environment."
  value       = azurerm_container_app_environment.capp_env.internal_load_balancer_enabled
}

output "spoke_ai_container_apps_environment_zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for the container apps environment."
  value       = azurerm_container_app_environment.capp_env.zone_redundancy_enabled
}

output "spoke_ai_container_apps_environment_mutual_tls_enabled" {
  description = "Whether mutual TLS is enabled for the container apps environment."
  value       = azurerm_container_app_environment.capp_env.mutual_tls_enabled
}

# =============================================================================
# WORKLOAD PROFILE OUTPUTS
# =============================================================================

output "spoke_ai_container_apps_environment_workload_profiles" {
  description = "The workload profiles configured for the container apps environment."
  value       = azurerm_container_app_environment.capp_env.workload_profile
}
