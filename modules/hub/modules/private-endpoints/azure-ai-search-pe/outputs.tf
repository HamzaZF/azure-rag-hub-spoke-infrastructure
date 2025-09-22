/*
  outputs.tf (Hub Private Endpoint - Azure AI Search)

  This file defines all outputs for the Kelix Azure Hub Private Endpoint (Azure AI Search) submodule.
*/

# -----------------------------------------------------------------------------
# Private Endpoint Outputs
# -----------------------------------------------------------------------------
output "hub_pe_ai_search_private_endpoint_id" {
  description = "The ID of the Azure AI Search private endpoint."
  value       = azurerm_private_endpoint.search_private_endpoint.id
}

output "hub_pe_ai_search_private_endpoint_ip" {
  description = "The private IP address assigned to the Azure AI Search private endpoint."
  value       = azurerm_private_endpoint.search_private_endpoint.private_service_connection[0].private_ip_address
}

# -----------------------------------------------------------------------------
# DNS Zone Outputs
# -----------------------------------------------------------------------------
output "hub_pe_ai_search_private_dns_zone_id" {
  description = "The ID of the private DNS zone for Azure AI Search."
  value       = azurerm_private_dns_zone.search_dns_zone.id
}

output "hub_pe_ai_search_private_dns_zone_name" {
  description = "The name of the private DNS zone for Azure AI Search."
  value       = azurerm_private_dns_zone.search_dns_zone.name
}

output "private_dns_zone_id" {
  description = "The ID of the AI Search private DNS zone"
  value       = azurerm_private_dns_zone.search_dns_zone.id
}

output "private_endpoint_id" {
  description = "The ID of the AI Search private endpoint"
  value       = azurerm_private_endpoint.search_private_endpoint.id
}
