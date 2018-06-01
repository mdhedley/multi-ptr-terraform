variable "vm_count" {
  type    = "string"
  default = "1"
}

variable "edge-cidr" {
  type = "string"
}

variable "edge-subnet" {
  type = "string"
}

variable "vm-type" {
  type    = "string"
  default = "f1-micro"
}

variable "send-count" {
  type = "string"
}

variable "vx_ip_edge_network" {
  type = "string"
}

variable "nat_vx_ip_start" {
  type = "string"
}

variable "vx_base_network" {
  type = "string"
}

variable "send-cidr" {
  type = "string"
}

variable "vx_cidr_bits" {}

locals {
  first_octet  = "${element(split(".",element(split("/",var.edge-cidr),0)),0)}"
  second_octet = "${element(split(".",element(split("/",var.edge-cidr),0)),1)}"
  third_octet  = "${element(split(".",element(split("/",var.edge-cidr),0)),2)}"
  fourth_octet = "${element(split(".",element(split("/",var.edge-cidr),0)),3)}"

  network_address   = "${local.first_octet}.${local.second_octet}.${local.third_octet}"
  starting_ip       = "${local.fourth_octet + 5}"
  send_first_octet  = "${element(split(".",element(split("/",var.send-cidr),0)),0)}"
  send_second_octet = "${element(split(".",element(split("/",var.send-cidr),0)),1)}"
  send_third_octet  = "${element(split(".",element(split("/",var.send-cidr),0)),2)}"
  send_fourth_octet = "${element(split(".",element(split("/",var.send-cidr),0)),3)}"

  send_network_address = "${local.send_first_octet}.${local.send_second_octet}.${local.send_third_octet}"
  send_starting_ip     = "${local.send_fourth_octet + 5}"
  ip_name_prefix       = "edge-vm-ip"
  ex_name_prefix       = "edge-vm-pip"
  vm_name_prefix       = "edge-vm"
  vm_image             = "debian-cloud/debian-8"

  vx_ip_edge_network = "192.168.1"
  vx_ip_start        = "5"
}
