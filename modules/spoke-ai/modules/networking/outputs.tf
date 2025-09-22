/*
  outputs.tf - Spoke AI Networking Module Outputs

  This file defines all outputs for the AI spoke networking module,
  providing resource IDs and information for cross-module integration.
*/

# =============================================================================
# VIRTUAL NETWORK OUTPUTS
# =============================================================================

output "spoke_ai_networking_vnet_id" {
  description = "The ID of the AI spoke virtual network."
  value       = azurerm_virtual_network.vnet_ai.id
}

output "spoke_ai_networking_vnet_name" {
  description = "The name of the AI spoke virtual network."
  value       = azurerm_virtual_network.vnet_ai.name
}

# =============================================================================
# SUBNET OUTPUTS
# =============================================================================

output "spoke_ai_networking_subnet_pe_id" {
  description = "The ID of the private endpoints subnet in the AI spoke."
  value       = azurerm_subnet.subnet_pe.id
}

output "spoke_ai_networking_subnet_pe_name" {
  description = "The name of the private endpoints subnet in the AI spoke."
  value       = azurerm_subnet.subnet_pe.name
}

output "spoke_ai_networking_subnet_cappenv_id" {
  description = "The ID of the container apps environment subnet in the AI spoke."
  value       = azurerm_subnet.subnet_cappenv.id
}

output "spoke_ai_networking_subnet_cappenv_name" {
  description = "The name of the container apps environment subnet in the AI spoke."
  value       = azurerm_subnet.subnet_cappenv.name
}

# =============================================================================
# NETWORK SECURITY GROUP OUTPUTS
# =============================================================================

output "spoke_ai_networking_nsg_pe_id" {
  description = "The ID of the private endpoints network security group."
  value       = azurerm_network_security_group.nsg_pe.id
}

output "spoke_ai_networking_nsg_pe_name" {
  description = "The name of the private endpoints network security group."
  value       = azurerm_network_security_group.nsg_pe.name
}

# =============================================================================
# VIRTUAL NETWORK PEERING OUTPUTS
# =============================================================================

# output "spoke_ai_networking_peering_ai_to_hub_id" {
#   description = "The ID of the AI to hub virtual network peering."
#   value       = azurerm_virtual_network_peering.ai_to_hub.id
# }

# output "spoke_ai_networking_peering_hub_to_ai_id" {
#   description = "The ID of the hub to AI virtual network peering."
#   value       = azurerm_virtual_network_peering.hub_to_ai.id
# } 