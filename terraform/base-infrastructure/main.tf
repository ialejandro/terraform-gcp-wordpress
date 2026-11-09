#
# VPC
#
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.3"

  project_id   = var.project_id
  network_name = var.network_name
  description  = var.network_description
  routing_mode = var.routing_mode

  subnets = var.subnets

  ingress_rules = var.ingress_rules
}

#
# DNS
#
module "dns_public_zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 7.0"

  project_id = var.project_id
  type       = "public"
  name       = "wordpress-public"
  domain     = var.dns_name

  description = "WordPress public zone"
}

module "dns_private_zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 7.0"

  project_id = var.project_id
  type       = "private"
  name       = "wordpress-private"
  domain     = var.dns_name

  description = "WordPress private zone"

  private_visibility_config_networks = [
    module.vpc.network_self_link
  ]
}

#
# CloudSQL
#
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-sql-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = module.vpc.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

module "mysql_db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "~> 28.3"

  name              = "wordpress-mysql-${random_id.db_name_suffix.hex}"
  project_id        = var.project_id
  database_version  = var.cloud_sql_version
  region            = var.region
  zone              = var.zone
  tier              = var.cloud_sql_tier
  disk_size         = var.cloud_sql_size
  availability_type = "ZONAL"

  deletion_protection = var.deletion_protection

  ip_configuration = {
    ipv4_enabled    = false
    private_network = module.vpc.network_id
  }

  database_flags = []

  db_name      = var.database_name
  db_charset   = "utf8mb4"
  db_collation = "utf8mb4_general_ci"

  user_name     = var.database_user
  user_password = var.database_password

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_dns_record_set" "mysql" {
  name         = "mysql.${var.dns_name}"
  managed_zone = module.dns_private_zone.name
  type         = "A"
  ttl          = 30

  rrdatas = [module.mysql_db.private_ip_address]
}

#
# Filestore
#
resource "google_filestore_instance" "this" {
  name     = var.filestore_name
  location = var.zone
  project  = var.project_id
  tier     = var.filestore_tier

  file_shares {
    name        = var.share_name
    capacity_gb = var.capacity_gb
  }

  networks {
    network      = module.vpc.network_name
    modes        = ["MODE_IPV4"]
    connect_mode = "DIRECT_PEERING"
  }
}

resource "google_dns_record_set" "nfs" {
  name         = "nfs.${var.dns_name}"
  managed_zone = module.dns_private_zone.name
  type         = "A"
  ttl          = 30

  rrdatas = [google_filestore_instance.this.networks[0].ip_addresses[0]]
}
