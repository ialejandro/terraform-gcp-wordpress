data "terraform_remote_state" "base" {
  backend = "gcs"

  config = {
    bucket = "<change-me>"
    prefix = "<change-me>"
  }
}

data "google_compute_image" "wordpress" {
  name    = "wordpress-base"
  project = var.project_id
}
