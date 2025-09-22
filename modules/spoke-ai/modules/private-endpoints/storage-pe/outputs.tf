/*
  outputs.tf (Spoke AI Private Endpoint - Storage)

  This file defines all output values for the Kelix Azure Spoke AI Storage Private Endpoint submodule.
*/

# -----------------------------------------------------------------------------
# Private Endpoint Outputs
# -----------------------------------------------------------------------------

output "spoke_ai_pe_storage_private_endpoint_id" {
  description = "The ID of the AI storage private endpoint."
  value       = azurerm_private_endpoint.storage_pe.id
}

output "spoke_ai_pe_storage_private_endpoint_name" {
  description = "The name of the AI storage private endpoint."
  value       = azurerm_private_endpoint.storage_pe.name
}

output "spoke_ai_pe_storage_private_endpoint_ip" {
  description = "The private IP address of the AI storage private endpoint."
  value       = azurerm_private_endpoint.storage_pe.private_service_connection[0].private_ip_address
}

# -----------------------------------------------------------------------------
# Private DNS Zone Outputs
# -----------------------------------------------------------------------------

output "spoke_ai_pe_storage_private_dns_zone_id" {
  description = "The ID of the AI storage private DNS zone."
  value       = azurerm_private_dns_zone.storage_dns_zone.id
}

output "spoke_ai_pe_storage_private_dns_zone_name" {
  description = "The name of the AI storage private DNS zone."
  value       = azurerm_private_dns_zone.storage_dns_zone.name
}