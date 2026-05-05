# RG
output "resource_group_name" {
  value = module.rg.name
}

# VNet
output "vnet_name" {
  value = module.vnet.vnet_name
}

output "vnet_id" {
  value = module.vnet.vnet_id
}

# Subnets
output "web_subnet_id" {
  value = module.vnet.web_subnet_id
}

output "app_subnet_id" {
  value = module.vnet.app_subnet_id
}

output "db_subnet_id" {
  value = module.vnet.db_subnet_id
}