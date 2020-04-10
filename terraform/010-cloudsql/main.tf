# private zone
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "private-sql-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = data.terraform_remote_state.vpc.outputs.vpc.self_link
}

# private peering
resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = data.terraform_remote_state.vpc.outputs.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# create random suffix for database
# the name can be reserve until 15 days after removed
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# instance cloudsql
resource "google_sql_database_instance" "mysql" {
  provider = google-beta

  name             = "wordpress-mysql-${random_id.db_name_suffix.hex}"
  database_version = var.cloud_sql_version
  region           = "europe-west1"

  settings {
    tier      = var.cloud_sql_tier
    disk_size = var.cloud_sql_size

    ip_configuration {
      ipv4_enabled    = false
      require_ssl     = false
      private_network = data.terraform_remote_state.vpc.outputs.vpc.id
    }

    location_preference {
      zone = "europe-west1-d"
    }

    backup_configuration {
      binary_log_enabled = false
      enabled            = false
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}
