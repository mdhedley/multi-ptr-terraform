resource "google_compute_network" "vpc" {
  name                    = "email-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "edge-subnet" {
  name          = "edge-subnet"
  ip_cidr_range = "${var.edge-cidr}"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "${var.region}"
}

resource "google_compute_subnetwork" "send-subnet" {
  name          = "sending-subnet"
  ip_cidr_range = "${var.send-cidr}"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "${var.region}"
}

resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = "${google_compute_network.vpc.self_link}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = "${google_compute_network.vpc.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/8"]
}
