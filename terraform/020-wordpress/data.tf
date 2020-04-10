# vpc
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

# IMAGE - DEBIAN 10
data "google_compute_image" "wordpress" {
  name = "wordpress-base"
}
