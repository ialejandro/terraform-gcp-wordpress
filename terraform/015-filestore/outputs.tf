# filestore values
output "filestore" {
  value = google_filestore_instance.filestore
}

# dns values
output "dns" {
  value = google_dns_record_set.nfs.name
}
