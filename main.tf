module "rg" {
  source      = "./modules/rg"
  rg-name     = var.rg-name
  location    = var.location
  environment = var.environment
  owner       = var.owner
}

module "vnet" {
  source = "./modules/vnet"

  vnet_name           = var.vnet_name
  location            = var.location
  resource_group_name = module.rg.name
}