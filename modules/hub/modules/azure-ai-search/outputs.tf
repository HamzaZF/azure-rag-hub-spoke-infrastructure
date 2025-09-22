/*
  outputs.tf (Hub Azure AI Search Submodule)

  This file defines all outputs for the Kelix Azure Hub AI Search submodule.
*/

# -----------------------------------------------------------------------------
# Service Outputs
# -----------------------------------------------------------------------------
output "hub_ai_search_service_id" {
  description = "The ID of the AI Search service."
  value       = azurerm_search_service.search_service.id
}

output "hub_ai_search_service_name" {
  description = "The name of the AI Search service."
  value       = azurerm_search_service.search_service.name
}

output "hub_ai_search_service_url" {
  description = "The URL of the AI Search service."
  value       = "https://${azurerm_search_service.search_service.name}.search.windows.net"
}

output "hub_ai_search_service_sku" {
  description = "The SKU of the AI Search service."
  value       = azurerm_search_service.search_service.sku
}

output "hub_ai_search_service_location" {
  description = "The location of the AI Search service."
  value       = azurerm_search_service.search_service.location
}

output "hub_ai_search_service_resource_group_name" {
  description = "The resource group name of the AI Search service."
  value       = azurerm_search_service.search_service.resource_group_name
}

output "hub_ai_search_service_replica_count" {
  description = "The number of replicas for the AI Search service."
  value       = azurerm_search_service.search_service.replica_count
}

output "hub_ai_search_service_partition_count" {
  description = "The number of partitions for the AI Search service."
  value       = azurerm_search_service.search_service.partition_count
}

output "hub_ai_search_service_public_network_access_enabled" {
  description = "Whether public network access is enabled for the AI Search service."
  value       = azurerm_search_service.search_service.public_network_access_enabled
}

# -----------------------------------------------------------------------------
# Keys Outputs
# -----------------------------------------------------------------------------
output "hub_ai_search_service_primary_key" {
  description = "The primary admin key for the Azure AI Search service."
  value       = azurerm_search_service.search_service.primary_key
  sensitive   = true
}

output "hub_ai_search_service_secondary_key" {
  description = "The secondary admin key for the Azure AI Search service."
  value       = azurerm_search_service.search_service.secondary_key
  sensitive   = true
}

output "hub_ai_search_service_query_keys" {
  description = "The query keys for the Azure AI Search service."
  value       = azurerm_search_service.search_service.query_keys
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Connection Information for Applications
# -----------------------------------------------------------------------------
output "hub_ai_search_api_endpoint" {
  description = "The complete API endpoint URL for search operations."
  value       = "https://${azurerm_search_service.search_service.name}.search.windows.net/"
}

output "hub_ai_search_api_version" {
  description = "The recommended API version for Azure AI Search."
  value       = "2023-11-01"
}

output "hub_ai_search_management_endpoint" {
  description = "The management endpoint for administrative operations."
  value       = "https://${azurerm_search_service.search_service.name}.search.windows.net/admin/"
}

# -----------------------------------------------------------------------------
# Service Capacity Information
# -----------------------------------------------------------------------------
output "hub_ai_search_service_search_units" {
  description = "The total search units (replicas × partitions) for the service."
  value       = azurerm_search_service.search_service.replica_count * azurerm_search_service.search_service.partition_count
}

output "hub_ai_search_service_storage_size_mb" {
  description = "The storage size in MB of the AI Search service."
  value       = azurerm_search_service.search_service.partition_count * (azurerm_search_service.search_service.sku == "standard" ? 25600 : (azurerm_search_service.search_service.sku == "basic" ? 2048 : 0))
}

output "azure_ai_search_id" {
  description = "The ID of the AI Search service."
  value       = azurerm_search_service.search_service.id
}

output "search_service_name" {
  description = "The name of the search service."
  value       = azurerm_search_service.search_service.name
}