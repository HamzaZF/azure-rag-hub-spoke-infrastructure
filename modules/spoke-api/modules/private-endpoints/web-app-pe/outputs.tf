/*
  outputs.tf (Spoke API Private Endpoint - Web App)

  This file defines all outputs for the Kelix Azure Spoke API Private Endpoint (Web App) submodule.
*/

# -----------------------------------------------------------------------------
# Private Endpoint Outputs
# -----------------------------------------------------------------------------
output "spoke_api_pe_web_app_private_endpoint_id" {
  description = "The ID of the Web App Private Endpoint."
  value       = azurerm_private_endpoint.wa_pe.id
}

output "spoke_api_pe_web_app_private_endpoint_ip" {
  description = "The private IP address of the Web App Private Endpoint."
  value       = azurerm_private_endpoint.wa_pe.private_service_connection[0].private_ip_address
}

# -----------------------------------------------------------------------------
# DNS Zone Outputs
# -----------------------------------------------------------------------------
output "spoke_api_pe_web_app_private_dns_zone_id" {
  description = "The ID of the private DNS zone for Web App."
  value       = azurerm_private_dns_zone.wa_pl.id
}
