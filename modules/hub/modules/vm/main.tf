/*
  main.tf (Hub VM Submodule)

  This file provisions the virtual machine (VM) for the Kelix Azure Hub environment.
*/

# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "hub"]
  suffix = [var.naming_region]
}

# -----------------------------------------------------------------------------
# Public IP (optional)
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "vm_public_ip" {
  count               = var.hub_vm_enable_public_ip ? 1 : 0
  name                = "${module.naming.public_ip.name}-${random_string.pip_suffix[0].result}"
  location            = var.hub_vm_location
  resource_group_name = var.hub_vm_resource_group_name
  allocation_method   = var.hub_vm_public_ip_allocation_method
  sku                 = var.hub_vm_public_ip_sku
}

resource "random_string" "pip_suffix" {
  count   = var.hub_vm_enable_public_ip ? 1 : 0
  length  = var.hub_vm_public_ip_random_suffix_length
  special = var.hub_vm_public_ip_random_suffix_special
  upper   = var.hub_vm_public_ip_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Network Interface
# -----------------------------------------------------------------------------
resource "azurerm_network_interface" "nic_vm" {
  name                = "${module.naming.network_interface.name}-${random_string.nic_suffix.result}"
  location            = var.hub_vm_location
  resource_group_name = var.hub_vm_resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.hub_vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.hub_vm_enable_public_ip ? azurerm_public_ip.vm_public_ip[0].id : null
  }
}

resource "random_string" "nic_suffix" {
  length  = var.hub_vm_nic_random_suffix_length
  special = var.hub_vm_nic_random_suffix_special
  upper   = var.hub_vm_nic_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Virtual Machine
# -----------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${module.naming.virtual_machine.name}-${random_string.vm_suffix.result}"

  resource_group_name = var.hub_vm_resource_group_name
  location            = var.hub_vm_location
  size                = var.hub_vm_size
  admin_username      = var.hub_vm_admin_username
  admin_password      = var.hub_vm_admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic_vm.id]

  os_disk {
    caching              = var.hub_vm_os_disk_caching //"ReadWrite"
    storage_account_type = var.hub_vm_os_disk_storage_account_type //"Standard_LRS"
  }

  source_image_reference {
    publisher = var.hub_vm_os_image_publisher //"Canonical"
    offer     = var.hub_vm_os_image_offer //"0001-com-ubuntu-server-jammy"
    sku       = var.hub_vm_os_image_sku //"22_04-lts"
    version   = var.hub_vm_os_image_version //"latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "random_string" "vm_suffix" {
  length  = var.hub_vm_random_suffix_length
  special = var.hub_vm_random_suffix_special
  upper   = var.hub_vm_random_suffix_upper
}


