# template: used by igm (intance group manager)
resource "google_compute_instance_template" "wordpress" {
  name        = "wordpress-template"
  description = "wordpress template"

  # firewall rules
  tags = ["${data.terraform_remote_state.vpc.outputs.firewall-common.name}"]

  instance_description = "wordpress"
  machine_type         = "f1-micro"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  # disk values
  disk {
    source_image = data.google_compute_image.wordpress.self_link
    disk_type    = "pd-standard"
    type         = "PERSISTENT"
    disk_size_gb = 10
    auto_delete  = true
    boot         = true
  }

  # network
  network_interface {
    network    = data.terraform_remote_state.vpc.outputs.vpc.self_link
    subnetwork = data.terraform_remote_state.vpc.outputs.public-01.self_link

    # ip public
    access_config {
      network_tier = "STANDARD"
    }
  }
}
