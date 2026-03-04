# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# IAM MODULE — Input Variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster (used for dependency ordering)."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the KSA."
  type        = string
}

variable "ksa_name" {
  description = "Name of the Kubernetes Service Account."
  type        = string
}

variable "gsa_roles" {
  description = "List of IAM roles to grant to the workload GSA."
  type        = list(string)
}

variable "environment" {
  description = "Environment label (dev, staging, prod)."
  type        = string
}
