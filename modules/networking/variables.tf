# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NETWORKING MODULE — Input Variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
}

variable "environment" {
  description = "Environment label (dev, staging, prod)."
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the private subnet."
  type        = string
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods."
  type        = string
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services."
  type        = string
}
