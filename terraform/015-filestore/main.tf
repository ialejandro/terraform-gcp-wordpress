resource "google_filestore_instance" "filestore" {
  name = "wordpress-filestore"
  zone = "europe-west1-d"
  tier = "STANDARD"

  file_shares {
    capacity_gb = 1024
    name        = "wordpress"
  }

  networks {
    network = data.terraform_remote_state.vpc.outputs.vpc.name
    modes   = ["MODE_IPV4"]
  }
}
