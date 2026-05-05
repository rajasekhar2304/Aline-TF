resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.location

  tags = {
    Environment = var.environment
    Owner       = var.owner
  }
}