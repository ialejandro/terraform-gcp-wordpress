resource "google_dns_record_set" "load_balancing" {
  name         = "<change-me>"
  managed_zone = data.terraform_remote_state.dns.outputs.wordpress_public_zone.name
  type         = "A"
  ttl          = 30

  rrdatas = ["${google_compute_global_forwarding_rule.allow_http.ip_address}"]
}
