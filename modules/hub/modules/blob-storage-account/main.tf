/*
  main.tf (Hub Blob Storage Account Submodule)

  This file provisions the blob storage account for the Kelix Azure Hub environment.
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
# Storage Account
# -----------------------------------------------------------------------------
resource "azurerm_storage_account" "kelix_storage_account_hub" {
  name                         = "${module.naming.storage_account.name}${random_string.storage_suffix.result}"
  resource_group_name          = var.hub_blob_storage_resource_group_name
  location                     = var.hub_blob_storage_location
  account_tier                 = var.hub_blob_storage_account_tier
  account_replication_type     = var.hub_blob_storage_account_replication_type
  account_kind = var.hub_blob_storage_account_kind

  # Security and compliance
  allow_nested_items_to_be_public = false

  min_tls_version              = var.hub_blob_storage_min_tls_version
  public_network_access_enabled = false
}

resource "random_string" "storage_suffix" {
  length  = var.hub_blob_storage_random_suffix_length
  special = var.hub_blob_storage_random_suffix_special
  upper   = var.hub_blob_storage_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Storage Container
# -----------------------------------------------------------------------------
resource "azurerm_storage_container" "container" {
  name                  = "${module.naming.storage_container.name}-${random_string.container_suffix.result}"
  storage_account_id    = azurerm_storage_account.kelix_storage_account_hub.id
  container_access_type = "private"
}

resource "random_string" "container_suffix" {
  length  = var.hub_blob_storage_container_random_suffix_length
  special = var.hub_blob_storage_container_random_suffix_special
  upper   = var.hub_blob_storage_container_random_suffix_upper
}
