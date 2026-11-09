data "terraform_remote_state" "base" {
  backend = "gcs"

  config = {
    bucket = "<change-me>"
    prefix = "<change-me>"
  }
}

data "google_compute_image" "debian" {
  family  = var.debian_image_family
  project = "debian-cloud"
}
