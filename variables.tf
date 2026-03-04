# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ROOT INPUT VARIABLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ──────────────────────────────────────────────────────────────────────────────
# Project & Region
# ──────────────────────────────────────────────────────────────────────────────
variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "The GCP zone for zonal resources (node pools)."
  type        = string
  default     = "europe-west1-b"
}

variable "environment" {
  description = "Environment label (e.g., dev, staging, prod). Used for resource naming."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────────────────────────────────────
variable "subnet_cidr" {
  description = "Primary CIDR range for the private subnet."
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods."
  type        = string
  default     = "10.16.0.0/14"
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services."
  type        = string
  default     = "10.20.0.0/20"
}

variable "master_cidr" {
  description = "CIDR range for the GKE control-plane VPC peering (/28 required)."
  type        = string
  default     = "172.16.0.0/28"

  validation {
    condition     = can(cidrhost(var.master_cidr, 0)) && split("/", var.master_cidr)[1] == "28"
    error_message = "master_cidr must be a valid /28 CIDR block."
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# Cluster
# ──────────────────────────────────────────────────────────────────────────────
variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
  default     = "vanguard-cluster"
}

variable "release_channel" {
  description = "GKE release channel (RAPID, REGULAR, STABLE)."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be one of: RAPID, REGULAR, STABLE."
  }
}

variable "authorized_networks" {
  description = "List of CIDR blocks allowed to access the GKE control-plane endpoint."
  type = list(object({
    display_name = string
    cidr_block   = string
  }))
  default = [
    {
      display_name = "iap-bastion"
      cidr_block   = "35.235.240.0/20"
    }
  ]
}

# ──────────────────────────────────────────────────────────────────────────────
# Node Pool
# ──────────────────────────────────────────────────────────────────────────────
variable "machine_type" {
  description = "Compute Engine machine type for the node pool."
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB for each node."
  type        = number
  default     = 50
}

variable "min_node_count" {
  description = "Minimum number of nodes per zone in the node pool."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes per zone in the node pool."
  type        = number
  default     = 3
}

# ──────────────────────────────────────────────────────────────────────────────
# IAM / Workload Identity
# ──────────────────────────────────────────────────────────────────────────────
variable "workload_identity_namespace" {
  description = "Kubernetes namespace for the workload identity KSA."
  type        = string
  default     = "default"
}

variable "workload_identity_ksa_name" {
  description = "Kubernetes Service Account name for workload identity binding."
  type        = string
  default     = "workload-ksa"
}

variable "workload_gsa_roles" {
  description = "IAM roles to grant to the workload Google Service Account."
  type        = list(string)
  default = [
    "roles/storage.objectViewer",
  ]
}

# ──────────────────────────────────────────────────────────────────────────────
# Artifact Registry
# ──────────────────────────────────────────────────────────────────────────────
variable "gar_repository_id" {
  description = "Artifact Registry repository ID."
  type        = string
  default     = "vanguard-docker"
}
