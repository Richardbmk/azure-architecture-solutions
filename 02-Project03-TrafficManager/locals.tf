# Define Local Values in Terraform
locals {
  owners      = var.business_divsion
  environment = var.environment
  #resource_name_prefix = "${var.business_divsion}-${var.environment}"
  resource_name_prefix = "${data.azurerm_resource_group.rg.location}-${var.business_divsion}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
} 