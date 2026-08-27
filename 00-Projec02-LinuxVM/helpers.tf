# Random String Resource
resource "random_string" "default" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

data "azurerm_resource_group" "rg" {
  name = var.existing_resource_group_name
}