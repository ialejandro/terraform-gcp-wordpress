output "instance_template_self_link" {
  description = "Self-link of the instance template"
  value       = module.instance_template.self_link
}

output "instance_group" {
  description = "The instance group URL"
  value       = module.mig.instance_group
}

output "load_balancer_ip" {
  description = "The external IP address of the load balancer"
  value       = google_compute_global_address.this.address
}

output "dns_record_name" {
  description = "DNS record name for the load balancer"
  value       = google_dns_record_set.load_balancing.name
}
