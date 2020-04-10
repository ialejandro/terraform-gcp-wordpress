resource "google_compute_instance" "wordpress" {
  name         = "wordpress-base"
  description  = "wordpress base image"
  machine_type = "f1-micro"
  zone         = "europe-west1-d"

  # firewall rules
  tags = ["${data.terraform_remote_state.vpc.outputs.firewall-common.name}"]

  boot_disk {
    auto_delete = false
    initialize_params {
      image = data.google_compute_image.debian.self_link
      type  = "pd-standard"
      size  = 10
    }
  }

  # network
  network_interface {
    network    = data.terraform_remote_state.vpc.outputs.vpc.self_link
    subnetwork = data.terraform_remote_state.vpc.outputs.public-01.self_link

    # public ip
    access_config {
      network_tier = "STANDARD"
    }
  }

  # ansible provisioning
  provisioner "local-exec" {
    working_dir = "ansible"

    command = <<EOF
ANSIBLE_SSH_ARGS='-o IdentitiesOnly=yes' ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${google_compute_instance.wordpress.network_interface.0.access_config.0.nat_ip},' \
-u wordpress --private-key ~/.ssh/id_rsa --extra-vars "tf_env_instance=${google_compute_instance.wordpress.name} tf_env_zone=${google_compute_instance.wordpress.zone} tf_env_project=${google_compute_instance.wordpress.project} tf_env_filestore_dns=${data.terraform_remote_state.filestore.outputs.dns}" \
main.yml
EOF
  }
}
