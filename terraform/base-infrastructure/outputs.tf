#
# VPC
#
output "network_name" {
  description = "The name of the VPC being created"
  value       = module.vpc.network_name
}

output "network_id" {
  description = "The ID of the VPC being created"
  value       = module.vpc.network_id
}

output "network_self_link" {
  description = "The URI of the VPC being created"
  value       = module.vpc.network_self_link
}

output "subnets_names" {
  description = "The names of the subnets being created"
  value       = module.vpc.subnets_names
}

output "subnets_self_links" {
  description = "The self-links of subnets being created"
  value       = module.vpc.subnets_self_links
}

#
# DNS
#
output "public_zone_name" {
  description = "Name of the public DNS zone"
  value       = module.dns_public_zone.name
}

output "public_zone_name_servers" {
  description = "Name servers for the public DNS zone"
  value       = module.dns_public_zone.name_servers
}

output "private_zone_name" {
  description = "Name of the private DNS zone"
  value       = module.dns_private_zone.name
}

#
# CloudSQL
#
output "mysql_instance_name" {
  description = "The name of the database instance"
  value       = module.mysql_db.instance_name
}

output "mysql_instance_connection_name" {
  description = "The connection name of the database instance"
  value       = module.mysql_db.instance_connection_name
}

output "mysql_private_ip_address" {
  description = "The private IP address of the database instance"
  value       = module.mysql_db.private_ip_address
}

output "mysql_dns_record_name" {
  description = "DNS record name for the MySQL instance"
  value       = google_dns_record_set.mysql.name
}

output "database_name" {
  description = "Name of the database"
  value       = var.database_name
}

#
# Filestore
#
output "filestore_instance_name" {
  description = "The name of the Filestore instance"
  value       = google_filestore_instance.this.name
}

output "filestore_ip_address" {
  description = "The IP address of the Filestore instance"
  value       = google_filestore_instance.this.networks[0].ip_addresses[0]
}

output "filestore_mount_point" {
  description = "The mount point of the Filestore instance"
  value       = "${google_filestore_instance.this.networks[0].ip_addresses[0]}:/${var.share_name}"
}

output "filestore_dns_record_name" {
  description = "DNS record name for the NFS instance"
  value       = google_dns_record_set.nfs.name
}
