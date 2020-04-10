# databases
resource "google_sql_database" "wordpress" {
  name     = var.cloud_sql_database
  instance = google_sql_database_instance.mysql.name

  depends_on = [google_sql_database_instance.mysql]
}

