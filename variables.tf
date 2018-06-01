//Provides the region for the resources
variable "region" {
  type    = "string"
  default = "us-west1"
}

//Selects the zone for the resources
variable "zone" {
  type    = "string"
  default = "us-west1-b"
}

//Selects the project for the resources
variable "project" {
  type    = "string"
  default = "mdh-learning"
}

// Sets the CIDR range for the edge nodes
variable "edge-cidr" {
  type    = "string"
  default = "10.0.1.0/24"
}

// Sets the CIDR range for the sending nodes
variable "sending-cidr" {
  type    = "string"
  default = "10.0.2.0/24"
}

variable "sending_node_count" {
  type    = "string"
  default = "2"
}

variable "edge_node_count" {
  type    = "string"
  default = "2"
}

locals {
  nat_vx_ip_network = "192.168.1"
  vx_ip_edge_start  = "5"

  send_vx_ip_network = "192.168.2"
  vx_ip_send_start   = "5"

  vx_base_network = "192.168.0.0"
  vx_cidr_bits    = "16"
}
