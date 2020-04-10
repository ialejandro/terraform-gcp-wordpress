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
