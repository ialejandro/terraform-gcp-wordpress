#
# Global
#
variable "project_id" {
  description = "The GCP project ID to deploy to"
  type        = string
  nullable    = false
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west1"
  nullable    = false
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "europe-west1-d"
  nullable    = false
}

#
# VPC
#
variable "network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "vpc-wordpress"
}

variable "network_description" {
  description = "Description of the VPC network"
  type        = string
  default     = "VPC for WordPress instances"
}

variable "routing_mode" {
  description = "The network routing mode"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "Routing mode must be REGIONAL or GLOBAL."
  }

  nullable = false
}

variable "subnets" {
  description = "The list of subnets to create"
  type = list(object({
    subnet_name           = string
    subnet_ip             = string
    subnet_region         = string
    subnet_private_access = optional(bool, true)
  }))
  default = [
    {
      subnet_name           = "private-01"
      subnet_ip             = "10.10.1.0/24"
      subnet_region         = "europe-west1"
      subnet_private_access = true
    },
    {
      subnet_name           = "public-01"
      subnet_ip             = "10.10.2.0/24"
      subnet_region         = "europe-west1"
      subnet_private_access = true
    }
  ]
}

variable "ingress_rules" {
  description = "List of ingress firewall rules"
  type = list(object({
    name                    = string
    description             = optional(string, null)
    disabled                = optional(bool, null)
    priority                = optional(number, null)
    destination_ranges      = optional(list(string), [])
    source_ranges           = optional(list(string), [])
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    log_config = optional(object({
      metadata = string
    }))
  }))
  default = [
    {
      name          = "allow-common"
      description   = "Allow common protocols from internet"
      source_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "icmp"
          ports    = []
        },
        {
          protocol = "tcp"
          ports    = ["80", "443", "22"]
        }
      ]
    }
  ]
}

#
# DNS
#
variable "dns_name" {
  description = "The DNS name for the zones (must end with a period)"
  type        = string

  validation {
    condition     = endswith(var.dns_name, ".")
    error_message = "DNS name must end with a trailing period (e.g. \"example.com.\")."
  }

  nullable = false
}

#
# CloudSQL
#
variable "cloud_sql_version" {
  description = "The MySQL version to use"
  type        = string
  default     = "MYSQL_8_0"

  validation {
    condition     = can(regex("^MYSQL_", var.cloud_sql_version))
    error_message = "CloudSQL version must be a valid MySQL version (e.g. MYSQL_8_0)."
  }
}

variable "cloud_sql_tier" {
  description = "The machine type to use for CloudSQL"
  type        = string
  default     = "db-f1-micro"
}

variable "cloud_sql_size" {
  description = "The size of the database disk in GB"
  type        = number
  default     = 10

  validation {
    condition     = var.cloud_sql_size >= 10
    error_message = "CloudSQL disk size must be at least 10 GB."
  }
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the CloudSQL instance"
  type        = bool
  default     = true
}

variable "database_name" {
  description = "The name of the database to create"
  type        = string
  default     = "wordpress"
  nullable    = false
}

variable "database_user" {
  description = "The name of the database user"
  type        = string
  default     = "wordpress"
  nullable    = false
}

variable "database_password" {
  description = "The password for the database user"
  type        = string
  sensitive   = true
  nullable    = false
}

#
# Filestore
#
variable "filestore_name" {
  description = "The name of the Filestore instance"
  type        = string
  default     = "wordpress-filestore"
}

variable "filestore_tier" {
  description = "The service tier for the Filestore instance"
  type        = string
  default     = "BASIC_HDD"

  validation {
    condition     = contains(["BASIC_HDD", "BASIC_SSD", "HIGH_SCALE_SSD", "ENTERPRISE", "ZONAL", "REGIONAL"], var.filestore_tier)
    error_message = "Filestore tier must be one of: BASIC_HDD, BASIC_SSD, HIGH_SCALE_SSD, ENTERPRISE, ZONAL, REGIONAL."
  }
}

variable "share_name" {
  description = "The name of the file share"
  type        = string
  default     = "wordpress"
}

variable "capacity_gb" {
  description = "The Filestore storage capacity in GB"
  type        = number
  default     = 1024

  validation {
    condition     = var.capacity_gb >= 1024
    error_message = "Filestore capacity must be at least 1024 GB for BASIC tiers."
  }
}
