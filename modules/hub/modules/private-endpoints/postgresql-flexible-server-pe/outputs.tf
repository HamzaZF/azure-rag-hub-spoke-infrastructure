/*
  outputs.tf (Hub Private Endpoint - PostgreSQL Flexible Server)

  This file defines all outputs for the Kelix Azure Hub Private Endpoint (PostgreSQL Flexible Server) submodule.
*/

# -----------------------------------------------------------------------------
# Private Endpoint Outputs
# -----------------------------------------------------------------------------
output "hub_pe_postgresql_private_endpoint_id" {
  description = "The ID of the PostgreSQL Flexible Server private endpoint."
  value       = azurerm_private_endpoint.psql_pe.id
}

output "hub_pe_postgresql_private_endpoint_ip" {
  description = "The private IP address assigned to the PostgreSQL Flexible Server private endpoint."
  value       = azurerm_private_endpoint.psql_pe.private_service_connection[0].private_ip_address
}

# -----------------------------------------------------------------------------
# DNS Zone Outputs
# -----------------------------------------------------------------------------
output "hub_pe_postgresql_private_dns_zone_id" {
  description = "The ID of the private DNS zone for PostgreSQL Flexible Server."
  value       = azurerm_private_dns_zone.postgres_pl.id
}

output "hub_pe_postgresql_private_dns_zone_name" {
  description = "The name of the private DNS zone for PostgreSQL Flexible Server."
  value       = azurerm_private_dns_zone.postgres_pl.name
}

output "private_dns_zone_id" {
  description = "The ID of the PostgreSQL private DNS zone"
  value       = azurerm_private_dns_zone.postgres_pl.id
}

output "private_endpoint_id" {
  description = "The ID of the PostgreSQL private endpoint"
  value       = azurerm_private_endpoint.psql_pe.id
}
