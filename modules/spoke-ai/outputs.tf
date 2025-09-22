/*
  outputs.tf - Spoke AI Module Outputs

  This file defines all outputs for the AI spoke module, providing resource IDs,
  names, and information for cross-module integration and external consumption.
*/

# =============================================================================
# RESOURCE GROUP OUTPUTS
# =============================================================================

output "resource_group_name" {
  description = "The name of the AI spoke resource group."
  value       = local.container_apps_resource_group_name
}



# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================

output "spoke_ai_vnet_id" {
  description = "The ID of the AI spoke virtual network."
  value       = module.networking.spoke_ai_networking_vnet_id
}

output "spoke_ai_vnet_name" {
  description = "The name of the AI spoke virtual network."
  value       = module.networking.spoke_ai_networking_vnet_name
}

output "spoke_ai_subnet_pe_id" {
  description = "The ID of the private endpoints subnet in the AI spoke."
  value       = module.networking.spoke_ai_networking_subnet_pe_id
}

output "spoke_ai_subnet_pe_name" {
  description = "The name of the private endpoints subnet in the AI spoke."
  value       = module.networking.spoke_ai_networking_subnet_pe_name
}

output "spoke_ai_cappenv_subnet_id" {
  description = "The ID of the container apps environment subnet in the AI spoke."
  value       = module.networking.spoke_ai_networking_subnet_cappenv_id
}

# =============================================================================
# STORAGE ACCOUNT OUTPUTS
# =============================================================================

output "spoke_ai_storage_account_id" {
  description = "The resource ID of the AI spoke storage account."
  value       = module.storage-account.spoke_ai_storage_account_id
}

output "spoke_ai_storage_account_name" {
  description = "The name of the AI spoke storage account."
  value       = module.storage-account.spoke_ai_storage_account_name
}

# =============================================================================
# PRIVATE ENDPOINT OUTPUTS
# =============================================================================

output "spoke_ai_storage_private_endpoint_id" {
  description = "The ID of the storage account private endpoint."
  value       = module.storage-pe.spoke_ai_pe_storage_private_endpoint_id
}

output "spoke_ai_storage_private_endpoint_ip" {
  description = "The private IP address of the storage account private endpoint."
  value       = module.storage-pe.spoke_ai_pe_storage_private_endpoint_ip
}

# =============================================================================
# PRIVATE DNS ZONE OUTPUTS
# =============================================================================

output "spoke_ai_storage_private_dns_zone_id" {
  description = "The ID of the storage account private DNS zone."
  value       = module.storage-pe.spoke_ai_pe_storage_private_dns_zone_id
}

output "spoke_ai_storage_private_dns_zone_name" {
  description = "The name of the storage account private DNS zone."
  value       = module.storage-pe.spoke_ai_pe_storage_private_dns_zone_name
}

# =============================================================================
# VIRTUAL NETWORK PEERING OUTPUTS
# =============================================================================

# output "spoke_ai_peering_ai_to_hub_id" {
#   description = "The ID of the AI to hub virtual network peering."
#   value       = module.networking.spoke_ai_networking_peering_ai_to_hub_id
# }

# output "spoke_ai_peering_hub_to_ai_id" {
#   description = "The ID of the hub to AI virtual network peering."
#   value       = module.networking.spoke_ai_networking_peering_hub_to_ai_id
# }
