/*
  outputs.tf (Hub Private Endpoint - Blob Storage)

  This file defines all outputs for the Kelix Azure Hub Private Endpoint (Blob Storage) submodule.
*/

# -----------------------------------------------------------------------------
# Private Endpoint Outputs
# -----------------------------------------------------------------------------
output "private_dns_zone_id" {
  description = "The ID of the blob storage private DNS zone"
  value       = azurerm_private_dns_zone.storage_blob_pl.id
}

output "private_endpoint_id" {
  description = "The ID of the blob storage private endpoint"
  value       = azurerm_private_endpoint.kelix_storage_blob.id
}

output "hub_pe_blob_storage_private_endpoint_ip" {
  description = "The private IP address of the Blob Storage private endpoint."
  value       = azurerm_private_endpoint.kelix_storage_blob.private_service_connection[0].private_ip_address
}

# -----------------------------------------------------------------------------
# DNS Zone Outputs
# -----------------------------------------------------------------------------
output "hub_pe_blob_storage_private_dns_zone_id" {
  description = "The ID of the private DNS zone for Blob Storage."
  value       = azurerm_private_dns_zone.storage_blob_pl.id
}

output "hub_pe_blob_storage_private_dns_zone_name" {
  description = "The name of the private DNS zone for Blob Storage."
  value       = azurerm_private_dns_zone.storage_blob_pl.name
}
