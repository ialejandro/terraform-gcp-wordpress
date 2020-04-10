# network
data "terraform_remote_state" "vpc" {
  backend = "gcs"

  config = {
    bucket = "<change-me>"
    prefix = "<change-me>"
  }
}
