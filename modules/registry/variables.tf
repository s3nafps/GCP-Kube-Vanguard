# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# REGISTRY MODULE — Input Variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region for the Artifact Registry."
  type        = string
}

variable "repository_id" {
  description = "ID of the Artifact Registry repository."
  type        = string
}

variable "environment" {
  description = "Environment label (dev, staging, prod)."
  type        = string
}

variable "ci_sa_email" {
  description = "Email of the CI/CD service account to grant writer access. Leave empty to skip."
  type        = string
  default     = ""
}
