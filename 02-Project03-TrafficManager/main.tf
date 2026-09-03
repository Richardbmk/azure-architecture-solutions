# Resource-1: Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "tm_profile" {
  name                   = "mytfdemo-${random_string.default.id}"
  resource_group_name    = data.azurerm_resource_group.rg.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "mytfdemo-${random_string.default.id}"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = local.common_tags
}

# Traffic Manager Endpoint - Project-EastUs
resource "azurerm_traffic_manager_azure_endpoint" "tm_endpoint_project_eastus" {
  name                = "tm-endpoint-project-eastus"
  profile_id        = azurerm_traffic_manager_profile.tm_profile.id
  target_resource_id  = data.terraform_remote_state.project_eastus.outputs.web_lb_public_ip_address_id
  weight              = 50
}


# Traffic Manager Endpoint - Project-WestUs
resource "azurerm_traffic_manager_azure_endpoint" "tm_endpoint_project_westus" {
  name                = "tm-endpoint-project-westus"
  profile_id          = azurerm_traffic_manager_profile.tm_profile.id
  target_resource_id  = data.terraform_remote_state.project_westus.outputs.web_lb_public_ip_address_id
  weight              = 50
}
