/*
  outputs.tf (Spoke API Application Gateway Submodule)

  This file defines all outputs for the Kelix Azure Spoke API Application Gateway submodule.
*/

# -----------------------------------------------------------------------------
# Application Gateway Outputs (Public/Private IP Configuration)
# -----------------------------------------------------------------------------
output "spoke_api_ag_id" {
  description = "The ID of the Application Gateway."
  value       = azurerm_application_gateway.appgw_waf.id
}

output "spoke_api_ag_name" {
  description = "The name of the Application Gateway."
  value       = azurerm_application_gateway.appgw_waf.name
}

output "spoke_api_ag_private_ip" {
  description = "The private IP address of the Application Gateway (always null for public configuration)."
  value       = null
}

output "spoke_api_ag_public_ip" {
  description = "The public IP address of the Application Gateway."
  value       = azurerm_public_ip.appgw_public_ip.ip_address
}

output "spoke_api_ag_public_ip_fqdn" {
  description = "The FQDN of the Application Gateway public IP."
  value       = azurerm_public_ip.appgw_public_ip.fqdn
}

output "spoke_api_ag_frontend_ip" {
  description = "The frontend IP address of the Application Gateway (public IP)."
  value       = azurerm_public_ip.appgw_public_ip.ip_address
}

output "spoke_api_ag_ssl_enabled" {
  description = "Whether SSL termination is enabled on the Application Gateway."
  value       = true
}

output "spoke_api_ag_endpoint_url" {
  description = "The HTTPS endpoint URL for the Application Gateway."
  value       = "https://${azurerm_public_ip.appgw_public_ip.ip_address}"
}
