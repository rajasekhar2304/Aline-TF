variable "vm_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}

variable "vm_size" {
  default = "Standard_B2als_v2"
}

variable "admin_username" {}
variable "admin_password" {}