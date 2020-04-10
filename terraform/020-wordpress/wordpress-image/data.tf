# network
data "terraform_remote_state" "vpc" {
  backend = "gcs"

  config = {
    bucket = "<change-me>"
    prefix = "<change-me>"
  }
}

# dns
data "terraform_remote_state" "dns" {
  backend = "gcs"

  config = {
    bucket = "<change-me>"
    prefix = "<change-me>"
  }
}

# filestore
data "terraform_remote_state" "filestore" {
  backend = "gcs"

  config = {
    bucket = "<change-me>"
    prefix = "<change-me>"
  }
}

# image: debian 10 (buster)
data "google_compute_image" "debian" {
  family  = "debian-10"
  project = "debian-cloud"
}
