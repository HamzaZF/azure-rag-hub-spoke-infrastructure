/*
  outputs.tf - Spoke AI Container App Module Outputs

  This file defines all output values for the AI spoke container app module,
  providing access to app details, configuration information, and integration
  data for other modules.
*/

# =============================================================================
# ALL CONTAINER APPS OUTPUTS
# =============================================================================

output "spoke_ai_container_apps" {
  description = "Map of all created container apps with their full configuration."
  value       = module.avm_res_app_containerapp
}

output "spoke_ai_container_app_ids" {
  description = "Map of container app resource IDs keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.resource_id }
}

output "spoke_ai_container_app_names" {
  description = "Map of container app names keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.name }
}

output "spoke_ai_container_app_locations" {
  description = "Map of container app locations keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.location }
}

# =============================================================================
# ENVIRONMENT INTEGRATION OUTPUTS
# =============================================================================

output "spoke_ai_container_app_environment_ids" {
  description = "Map of container app environment IDs keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.environment_id }
}

# =============================================================================
# IDENTITY OUTPUTS
# =============================================================================

output "spoke_ai_container_app_identities" {
  description = "Map of container app identity configurations keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.identity }
}

output "spoke_ai_container_app_identity_principal_ids" {
  description = "Map of container app identity principal IDs keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => length(v.identity) > 0 ? v.identity[0].principal_id : null }
}

output "spoke_ai_container_app_identity_tenant_ids" {
  description = "Map of container app identity tenant IDs keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => length(v.identity) > 0 ? v.identity[0].tenant_id : null }
}

# =============================================================================
# REVISION OUTPUTS
# =============================================================================

output "spoke_ai_container_app_latest_revision_names" {
  description = "Map of container app latest revision names keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.latest_revision_name }
}

output "spoke_ai_container_app_latest_ready_revision_names" {
  description = "Map of container app latest ready revision names keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.latest_ready_revision_name }
}

output "spoke_ai_container_app_latest_revision_fqdns" {
  description = "Map of container app latest revision FQDNs keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.latest_revision_fqdn }
}

# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================

output "spoke_ai_container_app_fqdn_urls" {
  description = "Map of container app FQDN URLs keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.fqdn_url }
}

output "spoke_ai_container_app_outbound_ip_addresses" {
  description = "Map of container app outbound IP addresses keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.outbound_ip_addresses }
}

# =============================================================================
# CUSTOM DOMAIN OUTPUTS
# =============================================================================

output "spoke_ai_container_app_custom_domains" {
  description = "Map of container app custom domains keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.custom_domains }
}

output "spoke_ai_container_app_custom_domain_verification_ids" {
  description = "Map of container app custom domain verification IDs keyed by app name."
  value       = { for k, v in module.avm_res_app_containerapp : k => v.custom_domain_verification_id }
}

# =============================================================================
# SUMMARY OUTPUTS
# =============================================================================

output "spoke_ai_container_app_count" {
  description = "Total number of container apps created."
  value       = length(module.avm_res_app_containerapp)
}

output "spoke_ai_container_app_names_list" {
  description = "List of all container app names."
  value       = values(module.avm_res_app_containerapp)[*].name
}
