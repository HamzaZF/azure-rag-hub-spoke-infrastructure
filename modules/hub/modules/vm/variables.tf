/*
  variables.tf (Hub VM Submodule)

  This file defines all input variables for the Kelix Azure Hub VM submodule.
*/

# -----------------------------------------------------------------------------
# VM Core Configuration
# -----------------------------------------------------------------------------

variable "hub_vm_os_disk_caching" {
  description = "The caching mode for the VM OS disk."
  type        = string
}

variable "hub_vm_os_disk_storage_account_type" {
  description = "The storage account type for the VM OS disk."
  type        = string
}

# OS Image Configuration
variable "hub_vm_os_image_publisher" {
  description = "The publisher of the OS image for the VM."
  type        = string
  default     = "Canonical"
}

variable "hub_vm_os_image_offer" {
  description = "The offer of the OS image for the VM."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "hub_vm_os_image_sku" {
  description = "The SKU of the OS image for the VM."
  type        = string
  default     = "22_04-lts"
}

variable "hub_vm_os_image_version" {
  description = "The version of the OS image for the VM."
  type        = string
  default     = "latest"
}

# The Azure region where the VM will be deployed.
variable "hub_vm_location" {
  description = "The Azure region where the VM will be deployed."
  type        = string
}

# -----------------------------------------------------------------------------
# Public IP Configuration
# -----------------------------------------------------------------------------

variable "hub_vm_enable_public_ip" {
  description = "Whether to create and assign a public IP to the VM."
  type        = bool
  default     = false
}

variable "hub_vm_public_ip_allocation_method" {
  description = "The allocation method for the public IP address."
  type        = string
  default     = "Static"
  validation {
    condition     = contains(["Static", "Dynamic"], var.hub_vm_public_ip_allocation_method)
    error_message = "Public IP allocation method must be either 'Static' or 'Dynamic'."
  }
}

variable "hub_vm_public_ip_sku" {
  description = "The SKU for the public IP address."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.hub_vm_public_ip_sku)
    error_message = "Public IP SKU must be either 'Basic' or 'Standard'."
  }
}

variable "hub_vm_public_ip_random_suffix_length" {
  description = "The length of the random suffix for the public IP name."
  type        = number
  default     = 4
}

variable "hub_vm_public_ip_random_suffix_special" {
  description = "Whether to include special characters in the public IP random suffix."
  type        = bool
  default     = false
}

variable "hub_vm_public_ip_random_suffix_upper" {
  description = "Whether to include uppercase letters in the public IP random suffix."
  type        = bool
  default     = false
}

# The name of the resource group where the VM will be created.
variable "hub_vm_resource_group_name" {
  description = "The name of the resource group where the VM will be created."
  type        = string
}

# The size of the virtual machine.
variable "hub_vm_size" {
  description = "The size of the virtual machine."
  type        = string
}

# Admin username for the virtual machine.
variable "hub_vm_admin_username" {
  description = "Admin username for the virtual machine."
  type        = string
}

# Admin password for the virtual machine.
variable "hub_vm_admin_password" {
  description = "Admin password for the virtual machine."
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------

# The ID of the subnet where the virtual machine will be deployed.
variable "hub_vm_subnet_id" {
  description = "The ID of the subnet where the virtual machine will be deployed."
  type        = string
}

# Random suffix configuration for network interface
variable "hub_vm_nic_random_suffix_length" {
  description = "The length of the random suffix for the network interface name."
  type        = number
  default     = 4
}

variable "hub_vm_nic_random_suffix_special" {
  description = "Whether to include special characters in the NIC random suffix."
  type        = bool
  default     = false
}

variable "hub_vm_nic_random_suffix_upper" {
  description = "Whether to include uppercase letters in the NIC random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for virtual machine
variable "hub_vm_random_suffix_length" {
  description = "The length of the random suffix for the virtual machine name."
  type        = number
  default     = 4
}

variable "hub_vm_random_suffix_special" {
  description = "Whether to include special characters in the VM random suffix."
  type        = bool
  default     = false
}

variable "hub_vm_random_suffix_upper" {
  description = "Whether to include uppercase letters in the VM random suffix."
  type        = bool
  default     = false
}

variable "naming_company" {
  description = "Company or organization name for resource naming."
  type        = string
}

variable "naming_product" {
  description = "Product or application name for resource naming."
  type        = string
}

variable "naming_environment" {
  description = "Deployment environment (e.g., dev, staging, prod) for resource naming."
  type        = string
}

variable "naming_region" {
  description = "Azure region for resource naming."
  type        = string
}

