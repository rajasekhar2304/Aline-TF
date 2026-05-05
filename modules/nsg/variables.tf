variable "nsg_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "allowed_ip" {}
variable "subnet2_cidr" {
    type = string
}
variable "web_subnet_id" {}
variable "app_subnet_id" {}
variable "db_subnet_id" {}