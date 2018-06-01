output "sending_subnet" {
  value = "${google_compute_subnetwork.send-subnet.self_link}"
}

output "edge_subnet" {
  value = "${google_compute_subnetwork.edge-subnet.self_link}"
}

output "vpc" {
  value = "${google_compute_network.vpc.self_link}"
}
