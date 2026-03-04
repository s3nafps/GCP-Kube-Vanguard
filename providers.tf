# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PROVIDER CONFIGURATION
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Pins the Google and Kubernetes provider versions and sets the required
# Terraform core version. All resources target the project and region
# specified in the root variables.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# Google Provider
# ──────────────────────────────────────────────────────────────────────────────
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# ──────────────────────────────────────────────────────────────────────────────
# Kubernetes Provider (configured after cluster creation)
# ──────────────────────────────────────────────────────────────────────────────
# NOTE: The kubernetes provider is configured here for the IAM module's
# kubernetes_service_account resource. In a real CI/CD pipeline you would
# typically configure this via kubeconfig or a data source.
# ──────────────────────────────────────────────────────────────────────────────
provider "kubernetes" {
  host                   = "https://${module.cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster.ca_certificate)
}

data "google_client_config" "default" {}
