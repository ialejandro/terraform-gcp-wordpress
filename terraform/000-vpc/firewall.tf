resource "google_compute_firewall" "common" {
  name    = "common"
  network = google_compute_network.vpc.name

  # allow icmp packages
  allow {
    protocol = "icmp"
  }

  # allow http / https / ssh
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }

  # from internet
  source_ranges = ["0.0.0.0/0"]
}
