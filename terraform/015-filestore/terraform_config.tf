provider "google" {
  project = "<change-me>"
  region  = "<change-me>"
}

terraform {
  backend "gcs" {
    bucket = "<change-me>"
    prefix = "<change-me>"
  }
}
