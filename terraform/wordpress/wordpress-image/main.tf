resource "google_compute_instance" "wordpress" {
  name         = "wordpress-base"
  description  = "WordPress base image build instance"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    auto_delete = false
    initialize_params {
      image = data.google_compute_image.debian.self_link
      type  = "pd-standard"
      size  = var.disk_size_gb
    }
  }

  network_interface {
    network    = data.terraform_remote_state.base.outputs.network_self_link
    subnetwork = data.terraform_remote_state.base.outputs.subnets_self_links[1]

    access_config {
      network_tier = "STANDARD"
    }
  }

  tags = data.terraform_remote_state.base.outputs.subnets_names

  provisioner "local-exec" {
    working_dir = "ansible"

    command = <<-EOF
      ANSIBLE_SSH_ARGS='-o IdentitiesOnly=yes' \
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook \
        -i '${self.network_interface[0].access_config[0].nat_ip},' \
        -u wordpress \
        --private-key ~/.ssh/id_rsa \
        --extra-vars "tf_env_instance=${self.name} tf_env_zone=${self.zone} tf_env_project=${self.project} tf_env_filestore_dns=${data.terraform_remote_state.base.outputs.filestore_mount_point}" \
        main.yml
    EOF
  }
}
