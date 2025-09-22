/*
  outputs.tf (Hub Private Endpoint - ACR)

  This file defines all outputs for the Kelix Azure Hub Private Endpoint (ACR) submodule.
*/

# -----------------------------------------------------------------------------
# Private Endpoint Outputs
# -----------------------------------------------------------------------------
output "hub_pe_acr_private_endpoint_id" {
  description = "The ID of the ACR private endpoint."
  value       = azurerm_private_endpoint.acr_pe.id
}

output "hub_pe_acr_private_endpoint_ip" {
  description = "The private IP address assigned to the ACR private endpoint."
  value       = azurerm_private_endpoint.acr_pe.private_service_connection[0].private_ip_address
}

# -----------------------------------------------------------------------------
# DNS Zone Outputs
# -----------------------------------------------------------------------------
output "hub_pe_acr_private_dns_zone_id" {
  description = "The ID of the private DNS zone for ACR."
  value       = azurerm_private_dns_zone.acr_pl.id
}