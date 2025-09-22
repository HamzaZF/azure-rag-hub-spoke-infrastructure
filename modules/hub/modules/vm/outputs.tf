/*
  outputs.tf (Hub VM Submodule)

  This file exposes key outputs from the Kelix Azure Hub VM submodule.
*/

# -----------------------------------------------------------------------------
# Network Interface Outputs
# -----------------------------------------------------------------------------

# The ID of the network interface
output "hub_vm_network_interface_id" {
  description = "The ID of the network interface."
  value       = azurerm_network_interface.nic_vm.id
}

# The name of the network interface
output "hub_vm_network_interface_name" {
  description = "The name of the network interface."
  value       = azurerm_network_interface.nic_vm.name
}

# The private IP address of the network interface
output "hub_vm_network_interface_private_ip" {
  description = "The private IP address of the network interface."
  value       = azurerm_network_interface.nic_vm.private_ip_address
}

# -----------------------------------------------------------------------------
# VM Outputs
# -----------------------------------------------------------------------------

# The ID of the Linux virtual machine
output "hub_vm_id" {
  description = "The ID of the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.vm.id
}

# The name of the Linux virtual machine
output "hub_vm_name" {
  description = "The name of the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.vm.name
}

# The admin username for the Linux virtual machine
output "hub_vm_admin_username" {
  description = "The admin username for the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.vm.admin_username
  sensitive   = true
}

# The private IP address of the Linux virtual machine
output "hub_vm_private_ip" {
  description = "The private IP address of the Linux virtual machine."
  value       = azurerm_network_interface.nic_vm.private_ip_address
}

# -----------------------------------------------------------------------------
# Managed Identity Outputs
# -----------------------------------------------------------------------------

# The principal ID of the VM's managed identity
output "hub_vm_principal_id" {
  description = "The principal ID of the VM's managed identity."
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

# The tenant ID of the VM's managed identity
output "hub_vm_tenant_id" {
  description = "The tenant ID of the VM's managed identity."
  value       = azurerm_linux_virtual_machine.vm.identity[0].tenant_id
}

# -----------------------------------------------------------------------------
# Public IP Outputs
# -----------------------------------------------------------------------------

# The ID of the public IP (if enabled)
output "hub_vm_public_ip_id" {
  description = "The ID of the public IP address (if enabled)."
  value       = length(azurerm_public_ip.vm_public_ip) > 0 ? azurerm_public_ip.vm_public_ip[0].id : null
}

# The public IP address (if enabled)
output "hub_vm_public_ip_address" {
  description = "The public IP address of the VM (if enabled)."
  value       = length(azurerm_public_ip.vm_public_ip) > 0 ? azurerm_public_ip.vm_public_ip[0].ip_address : null
}

# The FQDN of the public IP (if enabled)
output "hub_vm_public_ip_fqdn" {
  description = "The FQDN of the public IP address (if enabled)."
  value       = length(azurerm_public_ip.vm_public_ip) > 0 ? azurerm_public_ip.vm_public_ip[0].fqdn : null
}
