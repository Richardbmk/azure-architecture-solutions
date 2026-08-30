# Define Local Values in Terraform for General Use
locals {
  owners                = var.business_division
  environment           = var.environment
  resource_group_prefix = "${var.business_division}-${var.environment}"
  name                  = "${local.owners}-${local.environment}"

  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}



# Define Local Values in Terraform for NSG Rules
locals {
  web_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "120" : "22"
  }

  app_inbound_ports_map = {
    "100" : "80",
    "110" : "443",
    "120" : "8080",
    "130" : "22"
  }

  db_inbound_ports_map = {
    "100" : "3306",
    "110" : "1433",
    "120" : "5432"
  }

  bastion_inbound_ports_map = {
    "100" : "22",
    "110" : "3389"
  }

  web_vmnic_inbound_ports_map = {
    "100" : "80",
    "110" : "443",
    "120" : "22"
  }
}