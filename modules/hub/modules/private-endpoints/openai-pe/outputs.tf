/*
  outputs.tf (Hub Private Endpoint - OpenAI)

  This file defines all outputs for the Kelix Azure Hub Private Endpoint (OpenAI) submodule.
*/

# -----------------------------------------------------------------------------
# Private Endpoint Outputs
# -----------------------------------------------------------------------------
output "private_dns_zone_id" {
  description = "The ID of the OpenAI private DNS zone"
  value       = azurerm_private_dns_zone.openai_dns_zone.id
}

output "private_endpoint_id" {
  description = "The ID of the OpenAI private endpoint"
  value       = azurerm_private_endpoint.openai_private_endpoint.id
}

output "hub_pe_openai_private_endpoint_ip" {
  description = "The private IP address assigned to the OpenAI private endpoint."
  value       = azurerm_private_endpoint.openai_private_endpoint.private_service_connection[0].private_ip_address
}

# -----------------------------------------------------------------------------
# DNS Zone Outputs
# -----------------------------------------------------------------------------
output "hub_pe_openai_private_dns_zone_id" {
  description = "The ID of the private DNS zone for OpenAI."
  value       = azurerm_private_dns_zone.openai_dns_zone.id
}

output "hub_pe_openai_private_dns_zone_name" {
  description = "The name of the private DNS zone for OpenAI."
  value       = azurerm_private_dns_zone.openai_dns_zone.name
}
