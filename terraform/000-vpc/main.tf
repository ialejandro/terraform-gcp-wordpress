# network
resource "google_compute_network" "vpc" {
  name                    = "vpc-wordpress"
  description             = "vpc for wordpress instances"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# private subnet 01
resource "google_compute_subnetwork" "private-01" {
  name                     = "private-01"
  ip_cidr_range            = "10.10.1.0/24"
  region                   = "europe-west1"
  network                  = google_compute_network.vpc.self_link
  private_ip_google_access = true
}

# public subnet 01
resource "google_compute_subnetwork" "public-01" {
  name                     = "public-01"
  ip_cidr_range            = "10.10.2.0/24"
  region                   = "europe-west1"
  network                  = google_compute_network.vpc.self_link
  private_ip_google_access = true
}
