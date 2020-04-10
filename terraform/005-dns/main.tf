resource "google_dns_managed_zone" "public" {
  name        = "wordpress-public"
  description = "wordpress public zone"
  dns_name    = "<change-me>"
}

resource "google_dns_managed_zone" "private" {
  name        = "wordpress-private"
  description = "wordpress private zone"
  dns_name    = "<change-me>"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = data.terraform_remote_state.vpc.outputs.vpc.self_link
    }
  }
}
