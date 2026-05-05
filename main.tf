module "rg" {
  source      = "./modules/rg"
  rg-name     = var.rg-name
  location    = var.location
  environment = var.environment
  owner       = var.owner
}

module "vnet" {
  source              = "./modules/vnet"
  vnet_name           = var.vnet_name
  location            = var.location
  resource_group_name = module.rg.name
  vnet_cidr           = var.vnet_cidr
  subnet1_cidr        = var.subnet1_cidr
  subnet2_cidr        = var.subnet2_cidr
  subnet3_cidr        = var.subnet3_cidr
  subnet1_name        = var.subnet1_name
  subnet2_name        = var.subnet2_name
  subnet3_name        = var.subnet3_name
}

module "nsg" {
  source              = "./modules/nsg"
  nsg_name            = "aline-nsg"
  location            = var.location
  resource_group_name = module.rg.name
  web_subnet_id       = module.vnet.web_subnet_id
  app_subnet_id       = module.vnet.app_subnet_id
  db_subnet_id        = module.vnet.db_subnet_id
  allowed_ip          = var.allowed_ip
  subnet2_cidr        = module.vnet.app_subnet_cidr
}