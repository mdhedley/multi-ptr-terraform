variable "vm_count" {
  type    = "string"
  default = "1"
}

variable "sending-cidr" {
  type = "string"
}

variable "sending-subnet" {
  type = "string"
}

variable "vpc" {
  type = "string"
}

variable "vm-type" {
  type    = "string"
  default = "n1-standard-1"
}

variable "vx_base_network" {
  type = "string"
}

variable "send_vx_ip_start" {
  type = "string"
}

variable "vx_ip_send_network" {
  type = "string"
}

variable "vx_cidr_bits" {
  type = "string"
}

variable "edge_count" {
  type = "string"
}

variable "edge-cidr" {
  type = "string"
}

variable "vx_ip_edge_network" {
  type = "string"
}

variable "edge_vx_ip_start" {
  type = "string"
}

locals {
  first_octet  = "${element(split(".",element(split("/",var.sending-cidr),0)),0)}"
  second_octet = "${element(split(".",element(split("/",var.sending-cidr),0)),1)}"
  third_octet  = "${element(split(".",element(split("/",var.sending-cidr),0)),2)}"
  fourth_octet = "${element(split(".",element(split("/",var.sending-cidr),0)),3)}"

  network_address = "${local.first_octet}.${local.second_octet}.${local.third_octet}"
  starting_ip     = "${local.fourth_octet + 5}"

  edge_first_octet  = "${element(split(".",element(split("/",var.edge-cidr),0)),0)}"
  edge_second_octet = "${element(split(".",element(split("/",var.edge-cidr),0)),1)}"
  edge_third_octet  = "${element(split(".",element(split("/",var.edge-cidr),0)),2)}"
  edge_fourth_octet = "${element(split(".",element(split("/",var.edge-cidr),0)),3)}"

  edge_network_address = "${local.edge_first_octet}.${local.edge_second_octet}.${local.edge_third_octet}"
  edge_starting_ip     = "${local.edge_fourth_octet + 5}"

  ip_name_prefix = "send-vm-ip"
  vm_name_prefix = "send-vm"
  vm_image       = "debian-cloud/debian-8"
}
