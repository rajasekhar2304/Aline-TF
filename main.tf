module "rg" {
    source = "./modules/rg"
    rg-name = var.rg-name
    location = var.location
    environment = var.environment
    owner = var.owner
}