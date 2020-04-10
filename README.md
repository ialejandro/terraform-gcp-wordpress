# Terraform: Wordpress over Google Cloud Platform (GCP)

Deploy [Wordpress](https://wordpress.org/) over GCP with Terraform and Ansible.

## Requirements

* [pipenv](https://github.com/pypa/pipenv)
* [terraform v0.12.24](https://releases.hashicorp.com/terraform/0.12.24/)

## GCP: resources

* Network and two subnets: private and public.
* DNS with two zones: private and public.
* Filestore: shared wordpress files between all instance group.
* CloudSQL: save wordpress aplication data.
* VMs: deploy instances with wordpress base image.

## Ansible

With Ansible create the base wordpress image, after this image uses on template for instance group manager.
