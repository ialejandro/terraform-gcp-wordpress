# users
resource "google_sql_user" "wordpress" {
  name       = var.cloud_sql_user
  instance   = google_sql_database_instance.mysql.name
  host       = var.cloud_sql_host
  password   = var.cloud_sql_password
  depends_on = [google_sql_database_instance.mysql]
}
