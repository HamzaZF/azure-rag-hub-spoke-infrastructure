output "resource_group_name" {
  description = "The name of the API resource group."
  value       = local.resource_group_name
}

output "virtual_network_name" {
  description = "The name of the virtual network created by the networking module."
  value       = module.networking.spoke_api_networking_vnet_name
}

output "spoke_api_vnet_id" {
  description = "The ID of the hub virtual network."
  value       = module.networking.spoke_api_networking_vnet_id
}

output "spoke_api_wa_subnet_id" {
  description = "The ID of the Web Application subnet."
  value       = module.networking.spoke_api_networking_subnet_wa_id
}

# -----------------------------------------------------------------------------
# Backend Web App Outputs
# -----------------------------------------------------------------------------

output "spoke_api_web_app_principal_id" {
  description = "The principal_id of the backend web app's managed identity."
  value       = module.web-app-backend.spoke_api_web_app_principal_id
}

output "web_app_principal_id" {
  description = "The principal_id of the backend web app's managed identity."
  value       = module.web-app-backend.spoke_api_web_app_principal_id
}

output "web_app_id" {
  description = "The resource ID of the Backend Web App in the API spoke."
  value       = module.web-app-backend.spoke_api_web_app_id
}

output "spoke_api_web_app_name" {
  description = "The name of the Backend Web App."
  value       = module.web-app-backend.spoke_api_web_app_name
}

# -----------------------------------------------------------------------------
# Frontend Web App Outputs
# -----------------------------------------------------------------------------

output "spoke_api_frontend_app_id" {
  description = "The resource ID of the Frontend Web App in the API spoke."
  value       = module.web-app-frontend.spoke_api_frontend_app_id
}

output "spoke_api_frontend_app_name" {
  description = "The name of the Frontend Web App."
  value       = module.web-app-frontend.spoke_api_frontend_app_name
}

output "spoke_api_frontend_app_principal_id" {
  description = "The principal_id of the frontend web app's managed identity."
  value       = module.web-app-frontend.spoke_api_frontend_app_principal_id
}

output "spoke_api_frontend_app_url" {
  description = "The default URL of the Frontend Web App."
  value       = module.web-app-frontend.spoke_api_frontend_app_url
}

# Service Names for Testing
# ACR moved to hub - referencing hub ACR outputs
output "spoke_api_acr_name" {
  description = "The name of the Azure Container Registry (from hub)."
  value       = var.hub_acr_name
}

output "spoke_api_acr_id" {
  description = "The resource ID of the Azure Container Registry (from hub)."
  value       = var.hub_acr_resource_id
}

# -----------------------------------------------------------------------------
# Private Endpoint Outputs for Network Security Testing
# -----------------------------------------------------------------------------

# ACR Private Endpoint - Moved to hub
# ACR private endpoint outputs removed since ACR is now in hub

# Web App Private Endpoint
output "spoke_api_pe_web_app_private_endpoint_id" {
  description = "The ID of the Web App private endpoint."
  value       = module.web-app-pe.spoke_api_pe_web_app_private_endpoint_id
}

output "spoke_api_pe_web_app_private_endpoint_ip" {
  description = "The private IP address of the Web App private endpoint."
  value       = module.web-app-pe.spoke_api_pe_web_app_private_endpoint_ip
}

# -----------------------------------------------------------------------------
# DNS Zone Outputs
# -----------------------------------------------------------------------------

# ACR DNS Zone - Moved to hub
# ACR DNS zone output removed since ACR is now in hub

output "spoke_api_web_app_dns_zone_id" {
  description = "The ID of the Web App private DNS zone."
  value       = module.web-app-pe.spoke_api_pe_web_app_private_dns_zone_id
}

# -----------------------------------------------------------------------------
# Application Gateway Outputs
# -----------------------------------------------------------------------------

output "spoke_api_ag_frontend_ip" {
  description = "The frontend IP address of the Application Gateway (private IP for internal access)."
  value       = module.application_gateway.spoke_api_ag_frontend_ip
}

output "spoke_api_ag_private_ip" {
  description = "The private IP address of the Application Gateway (accessible via VNet integration)."
  value       = module.application_gateway.spoke_api_ag_private_ip
}

# -----------------------------------------------------------------------------
# Key Vault Outputs
# -----------------------------------------------------------------------------

output "spoke_api_key_vault_id" {
  description = "The ID of the API spoke Key Vault."
  value       = module.key-vault.spoke_api_key_vault_id
}

output "spoke_api_key_vault_name" {
  description = "The name of the API spoke Key Vault."
  value       = module.key-vault.spoke_api_key_vault_name
}

output "spoke_api_key_vault_uri" {
  description = "The URI of the API spoke Key Vault."
  value       = module.key-vault.spoke_api_key_vault_uri
}