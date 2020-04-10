# public zone values
output "wordpress_public_zone" {
  value = google_dns_managed_zone.public
}

# private zone values
output "wordpress_private_zone" {
  value = google_dns_managed_zone.private
}
