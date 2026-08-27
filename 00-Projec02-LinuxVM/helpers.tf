# Random String Resource
resource "random_string" "default" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

# Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name = "${local.resource_group_prefix}-${var.resource_group_name}-${random_string.default.id}"
  location = var.resource_group_location
  tags = local.common_tags
}