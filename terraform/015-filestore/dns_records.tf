resource "google_dns_record_set" "nfs" {
  name         = "nfs.${data.terraform_remote_state.dns.outputs.wordpress_private_zone.dns_name}"
  managed_zone = data.terraform_remote_state.dns.outputs.wordpress_private_zone.name
  type         = "A"
  ttl          = 30

  rrdatas = ["${google_filestore_instance.filestore.networks[0].ip_addresses[0]}"]
}
