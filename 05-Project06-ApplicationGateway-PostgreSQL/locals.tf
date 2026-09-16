# Define Local Values in Terraform for General Use
locals {
  owners                = var.business_division
  environment           = var.environment
  resource_group_prefix = "${var.business_division}-${var.resource_location}"
  name                  = "${local.owners}-${var.resource_location}"

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

  ag_inbound_ports_map = {
    "100" : "80",
    "110" : "443",
    "130" : "65200-65535"
  }

  # Generic 
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}-rdrcfg"


  # App1
  backend_address_pool_name_app1 = "${azurerm_virtual_network.vnet.name}-beap-app1"
  http_setting_name_app1         = "${azurerm_virtual_network.vnet.name}-be-htst-app1"
  probe_name_app1                = "${azurerm_virtual_network.vnet.name}-be-probe-app1"

  # HTTP Listener -  Port 80
  listener_name_http             = "${azurerm_virtual_network.vnet.name}-lstn-http"
  request_routing_rule_name_http = "${azurerm_virtual_network.vnet.name}-rqrt-http"
  frontend_port_name_http        = "${azurerm_virtual_network.vnet.name}-feport-http"


  # HTTPS Listener -  Port 443
  listener_name_https             = "${azurerm_virtual_network.vnet.name}-lstn-https"
  request_routing_rule_name_https = "${azurerm_virtual_network.vnet.name}-rqrt-https"
  frontend_port_name_https        = "${azurerm_virtual_network.vnet.name}-feport-https"
  ssl_certificate_name            = "my-cert-1"
  ssl_certificate_name_keyvault   = "keyvault-my-cert-1"

  # Choose backend pool
  app1_backend_pool_id = one([
    for pool in azurerm_application_gateway.web_ag.backend_address_pool :
    pool.id
    if pool.name == local.backend_address_pool_name_app1
  ])

  # Static HTML pages for Azure Application Gateway
  pages = ["index.html", "error.html", "502.html", "403.html"]
}