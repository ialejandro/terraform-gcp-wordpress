mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id        = "test-project"
  dns_name          = "example.com."
  database_password = "test-password"
}

run "plan_with_defaults" {
  command = plan

  assert {
    condition     = google_filestore_instance.this.name == "wordpress-filestore"
    error_message = "Filestore instance should use the default name."
  }
}

run "rejects_non_mysql_version" {
  command = plan

  variables {
    cloud_sql_version = "POSTGRES_15"
  }

  expect_failures = [var.cloud_sql_version]
}
