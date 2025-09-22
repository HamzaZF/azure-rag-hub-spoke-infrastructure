module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "backend"]
  suffix = [var.naming_region]
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "spoke_api_key_vault" {
  name                        = replace("${module.naming.key_vault.name}${random_string.kv_suffix.result}", "-", "")
  location                    = var.spoke_api_key_vault_location
  resource_group_name         = var.spoke_api_key_vault_resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization = true
  public_network_access_enabled = false

  sku_name = var.spoke_api_key_vault_sku_name

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "SetIssuers",
      "Update",
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey",
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set",
    ]
  }
}

resource "random_string" "kv_suffix" {
  length  = var.spoke_api_key_vault_random_suffix_length
  special = var.spoke_api_key_vault_random_suffix_special
  upper   = var.spoke_api_key_vault_random_suffix_upper
}

# resource "azurerm_key_vault_certificate" "spoke_api_key_vault_certificate" {
#   name = "ssl-certificate-app-gateway"
#   key_vault_id = azurerm_key_vault.spoke_api_key_vault.id
#   certificate{
#     contents = filebase64(var.spoke_api_ag_ssl_certificate_path)
#     password = var.spoke_api_ag_ssl_certificate_password
#   }
# }