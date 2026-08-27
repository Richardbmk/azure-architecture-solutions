# Define Local Values in Terraform
locals {
  owners                = var.business_division
  environment           = var.environment
  resource_group_prefix = "${var.business_division}-${var.environment}"
  name                  = "${local.owners}-${local.environment}"

  ## Locals Block for Security Rules
  web_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "120" : "22"
  }

  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}