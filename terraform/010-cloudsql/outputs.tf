# database values
output "database" {
  value = google_sql_database_instance.mysql
}

# dns values
output "dns" {
  value = google_dns_record_set.mysql.name
}
