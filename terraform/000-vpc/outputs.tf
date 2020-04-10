# vpc values
output "vpc" {
  value = google_compute_network.vpc
}

# private subnet values
output "private-01" {
  value = google_compute_subnetwork.private-01
}

# public subnet values
output "public-01" {
  value = google_compute_subnetwork.public-01
}

# firewall values
output "firewall-common" {
  value = google_compute_firewall.common
}
