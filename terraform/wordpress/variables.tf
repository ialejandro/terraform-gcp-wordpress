variable "project_id" {
  description = "The GCP project ID to deploy to"
  type        = string
  nullable    = false
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "The zone for the instance group"
  type        = string
  default     = "europe-west1-d"
}

variable "machine_type" {
  description = "The machine type for WordPress instances"
  type        = string
  default     = "e2-micro"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10

  validation {
    condition     = var.disk_size_gb >= 10
    error_message = "Boot disk size must be at least 10 GB."
  }
}

variable "disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"

  validation {
    condition     = contains(["pd-standard", "pd-ssd", "pd-balanced"], var.disk_type)
    error_message = "Disk type must be one of: pd-standard, pd-ssd, pd-balanced."
  }
}

variable "target_size" {
  description = "Number of instances in the managed instance group"
  type        = number
  default     = 1

  validation {
    condition     = var.target_size >= 1
    error_message = "Target size must be at least 1."
  }
}

variable "wordpress_server_name" {
  description = "Server name for the WordPress installation"
  type        = string
  default     = "wordpress.example.com"
}

variable "wordpress_server_admin" {
  description = "Server admin email for the WordPress installation"
  type        = string
  default     = "webmaster@example.com"
}

variable "wordpress_config" {
  description = "WordPress configuration options"
  type = object({
    version  = optional(string, "6.7")
    language = optional(string, "es_ES")
    base_url = optional(string, "https://es.wordpress.org")
  })
  default = {}
}
