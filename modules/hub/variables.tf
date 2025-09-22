/*
  variables.tf (Hub Module)

  This file defines all input variables for the Kelix Azure Hub module.
*/

# -----------------------------------------------------------------------------
# Hub Core Variables
# -----------------------------------------------------------------------------

# The name of the resource group for hub resources.
variable "hub_resource_group_name" {
  description = "The name of the resource group for hub resources."
  type        = string
}

# The Azure region where hub resources will be deployed.
variable "hub_location" {
  description = "The Azure region where hub resources will be deployed."
  type        = string
}

# The address space for the hub virtual network.
variable "hub_vnet_address_space" {
  description = "The address space for the hub virtual network."
  type        = list(string)
}



# The address prefix for the private endpoints subnet in the hub networking module.
variable "hub_pe_subnet_prefix" {
  description = "The address prefix for the private endpoints subnet in the hub networking module."
  type        = string
}

# The address prefix for the virtual machine subnet in the hub networking module.
variable "hub_vm_subnet_prefix" {
  description = "The address prefix for the virtual machine subnet in the hub networking module."
  type        = string
}

# The address prefix for the Azure Firewall subnet in the hub networking module.
variable "hub_azure_firewall_subnet_prefix" {
  description = "The address prefix for the Azure Firewall subnet in the hub networking module."
  type        = string
}


# -----------------------------------------------------------------------------
# VM Variables
# -----------------------------------------------------------------------------

# The size of the VM in the hub.
variable "hub_vm_size" {
  description = "The size of the VM in the hub."
  type        = string
}

# Admin username for the hub virtual machine (VM).
variable "hub_vm_admin_username" {
  description = "Admin username for the hub virtual machine (VM)."
  type        = string
}

# Admin password for the hub virtual machine (VM).
variable "hub_vm_admin_password" {
  description = "Admin password for the hub virtual machine (VM)."
  type        = string
  sensitive   = true
}

# OS Image Configuration
variable "hub_vm_os_image_publisher" {
  description = "The publisher of the OS image for the hub VM."
  type        = string
  default     = "Canonical"
}

variable "hub_vm_os_image_offer" {
  description = "The offer of the OS image for the hub VM."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "hub_vm_os_image_sku" {
  description = "The SKU of the OS image for the hub VM."
  type        = string
  default     = "22_04-lts"
}

variable "hub_vm_os_image_version" {
  description = "The version of the OS image for the hub VM."
  type        = string
  default     = "latest"
}

# -----------------------------------------------------------------------------
# PostgreSQL Variables
# -----------------------------------------------------------------------------

# The administrator login for the PostgreSQL Flexible Server in the hub.
variable "hub_postgresql_admin_login" {
  description = "The administrator login for the PostgreSQL Flexible Server in the hub."
  type        = string
}

# The administrator password for the PostgreSQL Flexible Server in the hub.
variable "hub_postgresql_admin_password" {
  description = "The administrator password for the PostgreSQL Flexible Server in the hub."
  type        = string
  sensitive   = true
}

# The SKU name for the PostgreSQL Flexible Server in the hub.
variable "hub_postgresql_sku_name" {
  description = "The SKU name for the PostgreSQL Flexible Server in the hub."
  type        = string
}

# The storage size in MB for the PostgreSQL Flexible Server in the hub
variable "hub_storage_mb" {
  description = "The storage size in MB for the PostgreSQL Flexible Server in the hub"
  type        = number
}

# The storage tier for the PostgreSQL Flexible Server in the hub.
variable "hub_storage_tier" {
  description = "The storage tier for the PostgreSQL Flexible Server in the hub."
  type        = string
}

# -----------------------------------------------------------------------------
# Azure Firewall Variables
# -----------------------------------------------------------------------------

# The SKU tier for the Azure Firewall in the hub.
variable "hub_azure_firewall_sku_tier" {
  description = "The SKU tier for the Azure Firewall in the hub (e.g., Standard, Premium)."
  type        = string
  default     = "Standard"
}

# The SKU name for the Azure Firewall in the hub.
variable "hub_azure_firewall_sku_name" {
  description = "The SKU name for the Azure Firewall in the hub (e.g., AZFW_VNet, AZFW_Hub)."
  type        = string
  default     = "AZFW_VNet"
}

# Random suffix configuration for Azure Firewall resources
variable "hub_azure_firewall_random_suffix_length" {
  description = "The length of the random suffix for the Azure Firewall resources."
  type        = number
  default     = 4
}

variable "hub_azure_firewall_random_suffix_special" {
  description = "Whether to include special characters in the Azure Firewall random suffix."
  type        = bool
  default     = false
}

variable "hub_azure_firewall_random_suffix_upper" {
  description = "Whether to include uppercase letters in the Azure Firewall random suffix."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Azure AI Search Variables
# -----------------------------------------------------------------------------

# The SKU for the Azure AI Search service in the hub (e.g., Basic, Standard, StorageOptimized).
variable "hub_ai_search_sku" {
  description = "The SKU for the Azure AI Search service in the hub (e.g., Basic, Standard, StorageOptimized)."
  type        = string
}

# List of IP addresses/CIDR ranges allowed for SSH access to the hub.
variable "hub_allowed_ssh_sources" {
  description = "List of IP addresses/CIDR ranges allowed for SSH access to the hub."
  type        = list(string)
}

variable "naming_company" {
  description = "Company name for naming convention"
  type        = string
}

variable "naming_product" {
  description = "Product name for naming convention"
  type        = string
}

variable "naming_environment" {
  description = "Environment name for naming convention"
  type        = string
}

variable "naming_region" {
  description = "Region for naming convention"
  type        = string
}

# The address prefix for the API spoke private endpoint subnet.
variable "spoke_api_networking_pe_subnet_prefix" {
  description = "The address prefix (CIDR) for the API spoke private endpoint subnet. Used for outbound NSG rules to allow access from hub VMs to API spoke private endpoints."
  type        = string
}

# The address prefix for the AI spoke private endpoint subnet.
variable "spoke_ai_networking_pe_subnet_prefix" {
  description = "The address prefix (CIDR) for the AI spoke private endpoint subnet. Used for outbound NSG rules to allow access from hub VMs to AI spoke private endpoints."
  type        = string
}

# The address prefix for the AI spoke container apps environment subnet.
variable "spoke_ai_networking_cappenv_subnet_prefix" {
  description = "The address prefix (CIDR) for the AI spoke container apps environment subnet. Used for outbound NSG rules to allow access from hub VMs to AI spoke container apps."
  type        = string
}



variable "hub_vm_os_disk_caching" {
  description = "The caching mode for the VM OS disk."
  type        = string
}

variable "hub_vm_os_disk_storage_account_type" {
  description = "The storage account type for the VM OS disk."
  type        = string
}

# -----------------------------------------------------------------------------
# Hub VM Public IP Configuration
# -----------------------------------------------------------------------------

variable "hub_vm_enable_public_ip" {
  description = "Whether to create and assign a public IP to the hub VM."
  type        = bool
  default     = false
}

variable "hub_vm_public_ip_allocation_method" {
  description = "The allocation method for the hub VM public IP address."
  type        = string
  default     = "Static"
  validation {
    condition     = contains(["Static", "Dynamic"], var.hub_vm_public_ip_allocation_method)
    error_message = "Public IP allocation method must be either 'Static' or 'Dynamic'."
  }
}

variable "hub_vm_public_ip_sku" {
  description = "The SKU for the hub VM public IP address."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.hub_vm_public_ip_sku)
    error_message = "Public IP SKU must be either 'Basic' or 'Standard'."
  }
}

# The source address prefix for the Databricks spoke public subnet (CORRECT for firewall rules)


# Blob Storage Configuration
variable "hub_blob_storage_account_tier" {
  description = "The tier of the hub blob storage account (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "hub_blob_storage_account_replication_type" {
  description = "The replication type for the hub blob storage account."
  type        = string
  default     = "GRS"
}

variable "hub_blob_storage_min_tls_version" {
  description = "The minimum TLS version for the hub blob storage account."
  type        = string
  default     = "TLS1_2"
}

variable "hub_blob_storage_account_kind" {
  description = "The kind of storage account for hub blob storage (StorageV2, BlobStorage, etc.)."
  type        = string
  default     = "StorageV2"
}

variable "hub_blob_storage_allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the hub blob storage account."
  type        = list(string)
  default     = []
}

variable "hub_blob_storage_allowed_ip_rules" {
  description = "List of IP addresses allowed to access the hub blob storage account."
  type        = list(string)
  default     = []
}

# OpenAI Configuration
variable "hub_openai_sku_name" {
  description = "The SKU name for the hub OpenAI cognitive account."
  type        = string
  default     = "S0"
}

variable "hub_openai_gpt4_1_mini_model_name" {
  description = "The model name for hub GPT-4o Mini deployment."
  type        = string
  default     = "gpt-4.1-mini"
}

variable "hub_openai_gpt4_1_mini_model_version" {
  description = "The model version for hub GPT-4o Mini deployment."
  type        = string
  default     = "2025-04-14"
}

variable "hub_openai_gpt4_1_mini_sku_name" {
  description = "The SKU name for hub GPT-4o Mini deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_gpt4_1_mini_sku_tier" {
  description = "The SKU tier for hub GPT-4o Mini deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_gpt4_1_mini_sku_size" {
  description = "The SKU size for hub GPT-4o Mini deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_gpt4_1_mini_capacity" {
  description = "The capacity for hub GPT-4o Mini deployment."
  type        = number
  default     = 1
}

variable "hub_openai_text_embedding_model_name" {
  description = "The model name for hub text embedding deployment."
  type        = string
  default     = "text-embedding-3-small"
}

variable "hub_openai_text_embedding_model_version" {
  description = "The model version for hub text embedding deployment."
  type        = string
  default     = "1"
}

variable "hub_openai_text_embedding_sku_name" {
  description = "The SKU name for hub text embedding deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_text_embedding_sku_tier" {
  description = "The SKU tier for hub text embedding deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_text_embedding_sku_size" {
  description = "The SKU size for hub text embedding deployment."
  type        = string
  default     = "Standard"
}

variable "hub_openai_text_embedding_capacity" {
  description = "The capacity for hub text embedding deployment."
  type        = number
  default     = 1
}

variable "hub_openai_custom_subdomain_name" {
  description = "The custom subdomain name for the hub OpenAI cognitive account."
  type        = string
}

# Azure AI Search Configuration
variable "hub_ai_search_hosting_mode" {
  description = "The hosting mode for the hub Azure AI Search service."
  type        = string
  default     = "Default"
}

variable "hub_ai_search_partition_count" {
  description = "The number of partitions for the hub Azure AI Search service."
  type        = string
  default     = "1"
}

variable "hub_ai_search_replica_count" {
  description = "The number of replicas for the hub Azure AI Search service."
  type        = string
  default     = "1"
}

variable "hub_ai_search_semantic_search_sku" {
  description = "The semantic search SKU for the hub Azure AI Search service."
  type        = string
  default     = "free"
}

# PostgreSQL Configuration
variable "hub_postgresql_version" {
  description = "The PostgreSQL version for the hub flexible server."
  type        = string
  default     = "12"
}

variable "hub_postgresql_zone" {
  description = "The availability zone for the hub PostgreSQL flexible server."
  type        = string
  default     = "1"
}

variable "hub_postgresql_active_directory_auth_enabled" {
  description = "Whether to enable Active Directory authentication for hub PostgreSQL."
  type        = bool
  default     = true
}

variable "hub_postgresql_password_auth_enabled" {
  description = "Whether to enable password authentication for hub PostgreSQL."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# ACR Configuration
# -----------------------------------------------------------------------------

variable "hub_acr_sku" {
  description = "The SKU for the hub Azure Container Registry."
  type        = string
  default     = "Basic"
}

variable "hub_acr_admin_enabled" {
  description = "Whether to enable admin user for the hub Azure Container Registry."
  type        = bool
  default     = false
}

variable "hub_acr_public_network_access_enabled" {
  description = "Whether to enable public network access for the hub Azure Container Registry."
  type        = bool
  default     = false
}

variable "hub_acr_random_suffix_length" {
  description = "The length of the random suffix for the hub Azure Container Registry."
  type        = number
  default     = 8
}

variable "hub_acr_random_suffix_special" {
  description = "Whether to include special characters in the random suffix for the hub Azure Container Registry."
  type        = bool
  default     = false
}

variable "hub_acr_random_suffix_upper" {
  description = "Whether to include uppercase letters in the random suffix for the hub Azure Container Registry."
  type        = bool
  default     = true
}
variable "acr_webhook_status" {
  description = "The status of the ACR webhook (enabled or disabled)."
  type        = string
}

variable "acr_webhook_scope" {
  description = "The scope for the ACR webhook (e.g., image:tag)."
  type        = string
}

variable "acr_webhook_name" {
  description = "The name for the ACR webhook."
  type        = string
  default     = ""
}

variable "spoke_api_vnet_address_space" {
  description = "The address space of the spoke API VNet."
  type        = list(string)
}

variable "spoke_ai_vnet_address_space" {
  description = "The address space of the spoke AI VNet."
  type        = list(string)
}