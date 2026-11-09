module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 15.4"

  project_id   = var.project_id
  region       = var.region
  name_prefix  = "wordpress"
  machine_type = var.machine_type
  tags         = [data.terraform_remote_state.base.outputs.subnets_names[1]]

  source_image         = data.google_compute_image.wordpress.self_link
  source_image_family  = ""
  source_image_project = ""
  disk_size_gb         = var.disk_size_gb
  disk_type            = var.disk_type
  auto_delete          = true

  network    = data.terraform_remote_state.base.outputs.network_self_link
  subnetwork = data.terraform_remote_state.base.outputs.subnets_self_links[1]

  access_config = [{
    nat_ip       = ""
    network_tier = "STANDARD"
  }]

  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
}

module "mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 15.4"

  project_id        = var.project_id
  region            = var.region
  hostname          = "wordpress"
  instance_template = module.instance_template.self_link
  target_size       = var.target_size

  named_ports = [{
    name = "http"
    port = 80
  }]
}

# Native load balancer (the old registry module capped google below 8).
# GCP resource names and providers match what the module created, so the moved blocks below
# keep the existing load balancer and its IP.
resource "google_compute_global_address" "this" {
  provider = google-beta

  name       = "wordpress-address"
  ip_version = "IPV4"
}

resource "google_compute_health_check" "this" {
  provider = google-beta

  name                = "wordpress-hc-default"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    request_path = "/"
    port         = 80
  }

  log_config {
    enable = false
  }
}

resource "google_compute_backend_service" "this" {
  provider = google-beta

  name                  = "wordpress-backend-default"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.this.self_link]

  backend {
    group = module.mig.instance_group
  }

  iap {
    enabled = false
  }
}

resource "google_compute_url_map" "this" {
  provider = google-beta

  name            = "wordpress-url-map"
  default_service = google_compute_backend_service.this.self_link
}

resource "google_compute_target_http_proxy" "this" {
  name    = "wordpress-http-proxy"
  url_map = google_compute_url_map.this.self_link
}

resource "google_compute_global_forwarding_rule" "this" {
  provider = google-beta

  name                  = "wordpress"
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_http_proxy.this.self_link
  ip_address            = google_compute_global_address.this.address
  port_range            = "80"
}

# Google health-check probe ranges to the instances.
resource "google_compute_firewall" "health_check" {
  name          = "wordpress-hc"
  network       = data.terraform_remote_state.base.outputs.network_self_link
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = [data.terraform_remote_state.base.outputs.subnets_names[1]]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

# Old addresses read from the module source (14.2.0); not checked against a state written by 12.x.
# A moved block whose source is absent from state is ignored. The old firewall
# (module.lb_http.google_compute_firewall.default-hc[0]) sat on network "default", so it is not
# moved: it is destroyed and the new rule is created.
moved {
  from = module.lb_http.google_compute_global_address.default[0]
  to   = google_compute_global_address.this
}

moved {
  from = module.lb_http.google_compute_health_check.default["default"]
  to   = google_compute_health_check.this
}

moved {
  from = module.lb_http.google_compute_backend_service.default["default"]
  to   = google_compute_backend_service.this
}

moved {
  from = module.lb_http.google_compute_url_map.default[0]
  to   = google_compute_url_map.this
}

moved {
  from = module.lb_http.google_compute_target_http_proxy.default[0]
  to   = google_compute_target_http_proxy.this
}

moved {
  from = module.lb_http.google_compute_global_forwarding_rule.http[0]
  to   = google_compute_global_forwarding_rule.this
}
