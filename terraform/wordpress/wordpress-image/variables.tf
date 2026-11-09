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
  description = "The GCP zone for the build instance"
  type        = string
  default     = "europe-west1-d"
}

variable "machine_type" {
  description = "The machine type for the build instance"
  type        = string
  default     = "e2-micro"
}

variable "debian_image_family" {
  description = "The Debian image family to use as base"
  type        = string
  default     = "debian-12"
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
