# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CLUSTER MODULE — Input Variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
}

variable "zone" {
  description = "GCP zone for the zonal cluster."
  type        = string
}

variable "environment" {
  description = "Environment label (dev, staging, prod)."
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
}

variable "network_id" {
  description = "Self-link of the VPC network."
  type        = string
}

variable "subnet_id" {
  description = "Self-link of the subnet."
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary IP range for pods."
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary IP range for services."
  type        = string
}

variable "master_cidr" {
  description = "CIDR block for the GKE control-plane VPC peering (/28)."
  type        = string
}

variable "authorized_networks" {
  description = "CIDR blocks allowed to access the control-plane."
  type = list(object({
    display_name = string
    cidr_block   = string
  }))
}

variable "release_channel" {
  description = "GKE release channel (RAPID, REGULAR, STABLE)."
  type        = string
}

variable "machine_type" {
  description = "Compute Engine machine type for nodes."
  type        = string
}

variable "disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
}

variable "min_node_count" {
  description = "Minimum nodes per zone."
  type        = number
}

variable "max_node_count" {
  description = "Maximum nodes per zone."
  type        = number
}
