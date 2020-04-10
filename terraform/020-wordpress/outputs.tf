# igm values
output "igm" {
  value = google_compute_instance_group_manager.wordpress
}

# fronted values
output "frontend" {
  value = google_compute_global_forwarding_rule.allow_http
}

# dns values
output "dns" {
  value = google_dns_record_set.load_balancing.name
}
