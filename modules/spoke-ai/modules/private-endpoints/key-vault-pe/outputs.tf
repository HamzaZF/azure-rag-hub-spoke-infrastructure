/*
  outputs.tf - Spoke AI Key Vault Private Endpoint Module Outputs

  This file defines all output values from the AI spoke Key Vault private endpoint module,
  providing essential resource information for integration and networking configuration.
*/

# =============================================================================
# PRIVATE ENDPOINT OUTPUTS
# =============================================================================

output "spoke_ai_pe_key_vault_id" {
  description = "The ID of the AI spoke Key Vault private endpoint."
  value       = azurerm_private_endpoint.kv_pe.id
}

output "spoke_ai_pe_key_vault_name" {
  description = "The name of the AI spoke Key Vault private endpoint."
  value       = azurerm_private_endpoint.kv_pe.name
}

output "spoke_ai_pe_key_vault_fqdn" {
  description = "The FQDN of the AI spoke Key Vault private endpoint."
  value       = azurerm_private_endpoint.kv_pe.private_service_connection[0].private_ip_address
}

output "spoke_ai_pe_key_vault_private_ip_address" {
  description = "The private IP address of the AI spoke Key Vault private endpoint."
  value       = azurerm_private_endpoint.kv_pe.private_service_connection[0].private_ip_address
}

# =============================================================================
# PRIVATE DNS ZONE OUTPUTS
# =============================================================================

output "spoke_ai_pe_key_vault_dns_zone_id" {
  description = "The ID of the private DNS zone for AI spoke Key Vault."
  value       = azurerm_private_dns_zone.kv_dns.id
}

output "spoke_ai_pe_key_vault_dns_zone_name" {
  description = "The name of the private DNS zone for AI spoke Key Vault."
  value       = azurerm_private_dns_zone.kv_dns.name
}
