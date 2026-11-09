# Terraform: Wordpress over Google Cloud Platform (GCP)

Deploy [Wordpress](https://wordpress.org/) over GCP with Terraform and Ansible.

## Requirements

* [Terraform](https://releases.hashicorp.com/terraform/) `~> 1.17` (`.terraform-version` pins 1.17.1, works with tfenv)
* Python 3.12 or newer and [pipenv](https://github.com/pypa/pipenv) for the Ansible image tooling
* Optional, for the local checks: [tflint](https://github.com/terraform-linters/tflint) and [trivy](https://github.com/aquasecurity/trivy)

## GCP: resources

* Network and two subnets: private and public.
* DNS with two zones: private and public.
* Filestore: shared wordpress files between all instance group.
* CloudSQL: save wordpress aplication data.
* VMs: deploy instances with wordpress base image.
* HTTP load balancer in front of the instance group.

## Deploy order

1. `terraform/base-infrastructure`: VPC, DNS, CloudSQL and Filestore.
2. `terraform/wordpress`: instance group and load balancer. It reads the first state through `terraform_remote_state`.

Create the state bucket first and change every `<change-me>` value. Each module runs `terraform init`, `plan`, `apply` on its own.

## Ansible

With Ansible create the base wordpress image, after this image uses on template for instance group manager.

```bash
cd pipenv && pipenv install --deploy && pipenv shell
```

## Checks

CI runs these on every pull request, with no credentials. Run them per module (`terraform/base-infrastructure`, `terraform/wordpress`, `terraform/wordpress/wordpress-image`):

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
tflint --init && tflint
trivy config --severity HIGH,CRITICAL --exit-code 1 .
terraform test        # base-infrastructure and wordpress only
```

CI never runs `apply` or `destroy`.

## Upgrading an existing deployment: state steps

This version replaces two things whose Terraform addresses changed. Back up the remote state and run `terraform plan` in each module before any `apply`. Apply without the steps below destroys and recreates these resources.

### Load balancer (`terraform/wordpress`)

The registry module was replaced by native resources named like the ones it created. `main.tf` has `moved` blocks for the global address, health check, backend service, url map, HTTP proxy and forwarding rule, so the load balancer and its external IP stay. The old addresses come from the module source (14.2.0), not from a state written by the previous 12.x release. If `plan` still shows those resources as destroy and create, move them by hand:

```bash
terraform state mv 'module.lb_http.google_compute_global_address.default[0]' google_compute_global_address.this
terraform state mv 'module.lb_http.google_compute_health_check.default["default"]' google_compute_health_check.this
terraform state mv 'module.lb_http.google_compute_backend_service.default["default"]' google_compute_backend_service.this
terraform state mv 'module.lb_http.google_compute_url_map.default[0]' google_compute_url_map.this
terraform state mv 'module.lb_http.google_compute_target_http_proxy.default[0]' google_compute_target_http_proxy.this
terraform state mv 'module.lb_http.google_compute_global_forwarding_rule.http[0]' google_compute_global_forwarding_rule.this
```

The health check firewall rule is not moved: the old one was on the `default` network, the new one (`wordpress-hc`) is on the project VPC. Plan shows one destroy and one create for it.

### Filestore (`terraform/base-infrastructure`)

The `GoogleCloudPlatform/filestore/google` module could not be resolved, so its resource address is unknown here and no `moved` block is shipped. Look it up with `terraform state list | grep filestore` against the existing state, then either:

```bash
terraform state mv '<old address>' google_filestore_instance.this
# or, if the instance is no longer in state
terraform import google_filestore_instance.this projects/<project>/locations/<zone>/instances/<filestore_name>
```

Do not apply while `plan` shows the Filestore instance being replaced: the WordPress files live there.
