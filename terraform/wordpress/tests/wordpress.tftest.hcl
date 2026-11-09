mock_provider "google" {}
mock_provider "google-beta" {}

override_data {
  target = data.terraform_remote_state.base
  values = {
    outputs = {
      network_self_link  = "projects/test-project/global/networks/wordpress-vpc"
      subnets_names      = ["private-subnet", "public-subnet"]
      subnets_self_links = ["projects/test-project/regions/europe-west1/subnetworks/private-subnet", "projects/test-project/regions/europe-west1/subnetworks/public-subnet"]
      public_zone_name   = "public-zone"
    }
  }
}

override_data {
  target = data.google_compute_image.wordpress
  values = {
    self_link = "projects/test-project/global/images/wordpress-base"
  }
}

override_data {
  target = module.mig.data.google_compute_zones.available
  values = {
    names = ["europe-west1-b", "europe-west1-c"]
  }
}

variables {
  project_id = "test-project"
}

run "plan_with_defaults" {
  command = plan

  assert {
    condition     = google_compute_health_check.this.http_health_check[0].request_path == "/"
    error_message = "Health check should probe /."
  }

  assert {
    condition     = google_compute_firewall.health_check.target_tags == toset(["public-subnet"])
    error_message = "Health check firewall should target the public subnet tag."
  }
}

run "rejects_small_disk" {
  command = plan

  variables {
    disk_size_gb = 5
  }

  expect_failures = [var.disk_size_gb]
}
