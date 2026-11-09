resource "google_dns_record_set" "load_balancing" {
  name         = "${var.wordpress_server_name}."
  managed_zone = data.terraform_remote_state.base.outputs.public_zone_name
  type         = "A"
  ttl          = 30

  rrdatas = [google_compute_global_address.this.address]
}
