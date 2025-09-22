/*
  outputs.tf (Hub Module)

  This file exposes key outputs from the Kelix Azure Hub module.
*/

# -----------------------------------------------------------------------------
# Resource Group Outputs
# -----------------------------------------------------------------------------

# The name of the resource group for the hub
output "hub_resource_group_name" {
  description = "The name of the resource group for the hub."
  value       = local.resource_group_name
}

# The Azure region of the resource group
output "hub_resource_group_location" {
  description = "The Azure region of the resource group."
  value       = var.hub_location
}

# -----------------------------------------------------------------------------
# Networking Outputs
# -----------------------------------------------------------------------------

# The name of the hub virtual network
output "hub_virtual_network_name" {
  description = "The name of the hub virtual network."
  value       = module.networking.hub_networking_vnet_name
}

# The ID of the hub virtual network
output "hub_vnet_id" {
  description = "The ID of the hub virtual network."
  value       = module.networking.hub_networking_vnet_id
}

# The ID of the VM subnet
output "hub_vm_subnet_id" {
  description = "The ID of the VM subnet."
  value       = module.networking.hub_networking_vm_subnet_id
}

# The ID of the private endpoint subnet
output "hub_pe_subnet_id" {
  description = "The ID of the private endpoint subnet."
  value       = module.networking.hub_networking_pe_subnet_id
}



# -----------------------------------------------------------------------------
# VM Outputs
# -----------------------------------------------------------------------------

# The principal ID of the VM's managed identity
output "hub_vm_principal_id" {
  description = "The principal ID of the VM's managed identity."
  value       = module.vm.hub_vm_principal_id
}

# The tenant ID of the VM's managed identity
output "hub_vm_tenant_id" {
  description = "The tenant ID of the VM's managed identity."
  value       = module.vm.hub_vm_tenant_id
}

# The ID of the VM
output "hub_vm_id" {
  description = "The ID of the VM."
  value       = module.vm.hub_vm_id
}

# The name of the VM
output "hub_vm_name" {
  description = "The name of the VM."
  value       = module.vm.hub_vm_name
}

# The private IP address of the VM
output "hub_vm_private_ip" {
  description = "The private IP address of the VM."
  value       = module.vm.hub_vm_private_ip
}

# The public IP address of the VM (if enabled)
output "hub_vm_public_ip_address" {
  description = "The public IP address of the VM (if enabled)."
  value       = module.vm.hub_vm_public_ip_address
}

# The public IP ID of the VM (if enabled)
output "hub_vm_public_ip_id" {
  description = "The public IP ID of the VM (if enabled)."
  value       = module.vm.hub_vm_public_ip_id
}

# The FQDN of the VM's public IP (if enabled)
output "hub_vm_public_ip_fqdn" {
  description = "The FQDN of the VM's public IP (if enabled)."
  value       = module.vm.hub_vm_public_ip_fqdn
}



# -----------------------------------------------------------------------------
# Naming Outputs (optional)
# -----------------------------------------------------------------------------

# The name of the hub resource group
output "hub_naming_resource_group" {
  description = "The name of the hub resource group."
  value       = local.resource_group_name
}

# DNS Zone Outputs (for root-level DNS links)
output "hub_pe_blob_storage_private_dns_zone_id" {
  description = "The ID of the private DNS zone for Blob Storage."
  value       = module.blob-storage-pe.hub_pe_blob_storage_private_dns_zone_id
}
output "hub_pe_openai_private_dns_zone_id" {
  description = "The ID of the private DNS zone for OpenAI."
  value       = module.openai-pe.hub_pe_openai_private_dns_zone_id
}
output "hub_pe_ai_search_private_dns_zone_id" {
  description = "The ID of the private DNS zone for Azure AI Search."
  value       = module.azure-ai-search-pe.hub_pe_ai_search_private_dns_zone_id
}
output "hub_pe_postgresql_private_dns_zone_id" {
  description = "The ID of the private DNS zone for PostgreSQL Flexible Server."
  value       = module.postgresql-flexible-server-pe.hub_pe_postgresql_private_dns_zone_id
}

# DNS Zone Name Outputs (for root-level DNS links)
output "hub_pe_blob_storage_private_dns_zone_name" {
  description = "The name of the private DNS zone for Blob Storage."
  value       = module.blob-storage-pe.hub_pe_blob_storage_private_dns_zone_name
}
output "hub_pe_openai_private_dns_zone_name" {
  description = "The name of the private DNS zone for OpenAI."
  value       = module.openai-pe.hub_pe_openai_private_dns_zone_name
}
output "hub_pe_ai_search_private_dns_zone_name" {
  description = "The name of the private DNS zone for Azure AI Search."
  value       = module.azure-ai-search-pe.hub_pe_ai_search_private_dns_zone_name
}
output "hub_pe_postgresql_private_dns_zone_name" {
  description = "The name of the private DNS zone for PostgreSQL Flexible Server."
  value       = module.postgresql-flexible-server-pe.hub_pe_postgresql_private_dns_zone_name
}

output "hub_blob_storage_account_id" {
  description = "The resource ID of the Blob Storage account."
  value       = module.blob-storage-account.hub_blob_storage_account_id
}
output "hub_postgresql_server_id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = module.postgresql-flexible-server.hub_postgresql_server_id
}
output "hub_ai_search_service_id" {
  description = "The ID of the AI Search service."
  value       = module.azure-ai-search.hub_ai_search_service_id
}
output "hub_openai_cognitive_account_id" {
  description = "The ID of the OpenAI Cognitive Service."
  value       = module.openai.hub_openai_cognitive_account_id
}

# Service Names for Testing
output "hub_blob_storage_account_name" {
  description = "The name of the Blob Storage account."
  value       = module.blob-storage-account.hub_blob_storage_account_name
}

output "hub_postgresql_server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = module.postgresql-flexible-server.hub_postgresql_server_name
}

output "hub_postgresql_server_fqdn" {
  description = "The fully qualified domain name of the PostgreSQL Flexible Server."
  value       = module.postgresql-flexible-server.hub_postgresql_server_fqdn
}

output "hub_postgresql_administrator_login" {
  description = "The administrator login name for the PostgreSQL Flexible Server."
  value       = module.postgresql-flexible-server.hub_postgresql_administrator_login
}

output "hub_postgresql_administrator_password" {
  description = "The administrator password for the PostgreSQL Flexible Server."
  value       = module.postgresql-flexible-server.hub_postgresql_administrator_password
  sensitive   = true
}

output "hub_ai_search_service_name" {
  description = "The name of the AI Search service."
  value       = module.azure-ai-search.hub_ai_search_service_name
}

# output "hub_openai_cognitive_account_name" {
#   description = "The name of the OpenAI Cognitive Service."
#   value       = module.openai.hub_openai_cognitive_account_name
# }

output "hub_openai_custom_subdomain_name" {
  description = "The custom subdomain name for the hub OpenAI service for managed identity access."
  value       = module.openai.hub_openai_custom_subdomain_name
}

# -----------------------------------------------------------------------------
# ACR Outputs
# -----------------------------------------------------------------------------

output "hub_acr_login_server" {
  description = "The login server for the hub Azure Container Registry."
  value       = module.acr.hub_acr_login_server
}

output "hub_acr_resource_id" {
  description = "The resource ID for the hub Azure Container Registry."
  value       = module.acr.hub_acr_id
}

output "hub_acr_name" {
  description = "The name of the hub Azure Container Registry."
  value       = module.acr.hub_acr_name
}

output "hub_pe_acr_private_endpoint_id" {
  description = "The ID of the ACR private endpoint."
  value       = module.acr-pe.hub_pe_acr_private_endpoint_id
}

output "hub_pe_acr_private_endpoint_ip" {
  description = "The private IP address of the ACR private endpoint."
  value       = module.acr-pe.hub_pe_acr_private_endpoint_ip
}

output "hub_pe_acr_private_dns_zone_id" {
  description = "The ID of the ACR private DNS zone."
  value       = module.acr-pe.hub_pe_acr_private_dns_zone_id
}

# -----------------------------------------------------------------------------
# Private Endpoint Outputs for Network Security Testing
# -----------------------------------------------------------------------------

# # Blob Storage Private Endpoint
# output "hub_pe_blob_storage_private_endpoint_id" {
#   description = "The ID of the Blob Storage private endpoint."
#   value       = module.blob-storage-pe.hub_pe_blob_storage_private_endpoint_id
# }

output "hub_pe_blob_storage_private_endpoint_ip" {
  description = "The private IP address of the Blob Storage private endpoint."
  value       = module.blob-storage-pe.hub_pe_blob_storage_private_endpoint_ip
}

# PostgreSQL Private Endpoint
output "hub_pe_postgresql_private_endpoint_id" {
  description = "The ID of the PostgreSQL private endpoint."
  value       = module.postgresql-flexible-server-pe.hub_pe_postgresql_private_endpoint_id
}

output "hub_pe_postgresql_private_endpoint_ip" {
  description = "The private IP address of the PostgreSQL private endpoint."
  value       = module.postgresql-flexible-server-pe.hub_pe_postgresql_private_endpoint_ip
}

# AI Search Private Endpoint
output "hub_pe_ai_search_private_endpoint_id" {
  description = "The ID of the AI Search private endpoint."
  value       = module.azure-ai-search-pe.hub_pe_ai_search_private_endpoint_id
}

output "hub_pe_ai_search_private_endpoint_ip" {
  description = "The private IP address of the AI Search private endpoint."
  value       = module.azure-ai-search-pe.hub_pe_ai_search_private_endpoint_ip
}

# # OpenAI Private Endpoint
# output "hub_pe_openai_private_endpoint_id" {
#   description = "The ID of the OpenAI private endpoint."
#   value       = module.openai-pe.hub_pe_openai_private_endpoint_id
# }

output "hub_pe_openai_private_endpoint_ip" {
  description = "The private IP address of the OpenAI private endpoint."
  value       = module.openai-pe.hub_pe_openai_private_endpoint_ip
}

# -----------------------------------------------------------------------------
# DNS Zone Outputs (for root-level DNS links)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Private DNS Zone IDs for Cross-VNet Linking
# -----------------------------------------------------------------------------
output "hub_blob_storage_private_dns_zone_id" {
  description = "The ID of the blob storage private DNS zone"
  value       = module.blob-storage-pe.private_dns_zone_id
}

output "hub_openai_private_dns_zone_id" {
  description = "The ID of the OpenAI private DNS zone"
  value       = module.openai-pe.private_dns_zone_id
}

output "hub_ai_search_private_dns_zone_id" {
  description = "The ID of the AI Search private DNS zone"
  value       = module.azure-ai-search-pe.private_dns_zone_id
}

output "hub_postgresql_private_dns_zone_id" {
  description = "The ID of the PostgreSQL private DNS zone"
  value       = module.postgresql-flexible-server-pe.private_dns_zone_id
}

output "hub_azure_firewall_public_ip_address" {
  description = "The public IP address of the Azure Firewall."
  value       = module.azure-firewall.hub_azure_firewall_public_ip_address
}