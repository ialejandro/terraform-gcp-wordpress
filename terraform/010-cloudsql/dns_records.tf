# dns record
resource "google_dns_record_set" "mysql" {
  name         = "mysql.${data.terraform_remote_state.dns.outputs.wordpress_private_zone.dns_name}"
  managed_zone = data.terraform_remote_state.dns.outputs.wordpress_private_zone.name
  type         = "A"
  ttl          = 30

  rrdatas = ["${google_sql_database_instance.mysql.first_ip_address}"]
}
