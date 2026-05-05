variable "vm_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}

variable "vm_size" {
  default = "Standard_B2as_v2"
}

variable "admin_username" {}
variable "admin_password" {}