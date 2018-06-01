provider "google" {
  region  = "${var.region}"
  zone    = "${var.zone}"
  project = "${var.project}"
}

module "vpc" {
  source    = "./vpc"
  region    = "${var.region}"
  edge-cidr = "${var.edge-cidr}"
  send-cidr = "${var.sending-cidr}"
}

module "sending_nodes" {
  source             = "./sending_node"
  vm_count           = "${var.sending_node_count}"
  sending-cidr       = "${var.sending-cidr}"
  sending-subnet     = "${module.vpc.sending_subnet}"
  vpc                = "${module.vpc.vpc}"
  edge_count         = "${var.edge_node_count}"
  vx_base_network    = "${local.vx_base_network}"
  vx_cidr_bits       = "${local.vx_cidr_bits}"
  send_vx_ip_start   = "${local.vx_ip_send_start}"
  vx_ip_send_network = "${local.send_vx_ip_network}"
  edge-cidr          = "${var.edge-cidr}"
  edge_vx_ip_start   = "${local.vx_ip_edge_start}"
  vx_ip_edge_network = "${local.nat_vx_ip_network}"
}

module "edge-nodes" {
  source             = "./edge_node"
  vm_count           = "${var.edge_node_count}"
  edge-cidr          = "${var.edge-cidr}"
  edge-subnet        = "${module.vpc.edge_subnet}"
  nat_vx_ip_start    = "${local.vx_ip_edge_start}"
  vx_ip_edge_network = "${local.nat_vx_ip_network}"
  send-count         = "${var.sending_node_count}"
  vx_base_network    = "${local.vx_base_network}"
  vx_cidr_bits       = "${local.vx_cidr_bits}"
  send-cidr          = "${var.sending-cidr}"
}
