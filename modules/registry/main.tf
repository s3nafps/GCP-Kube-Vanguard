# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# REGISTRY MODULE — Google Artifact Registry
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Provisions a Docker-format Artifact Registry repository and optionally
# grants push access to a CI/CD service account.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "google_artifact_registry_repository" "docker" {
  location      = var.region
  repository_id = var.repository_id
  project       = var.project_id
  format        = "DOCKER"
  description   = "Docker container images for GKE Vanguard (${var.environment})"

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  # Cleanup policy — keep the latest 10 tagged versions, delete untagged after 7 days
  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"

    condition {
      tag_state  = "UNTAGGED"
      older_than = "604800s" # 7 days
    }
  }

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"

    most_recent_versions {
      keep_count = 10
    }
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# IAM: Grant the CI/CD SA write access (if provided)
# ──────────────────────────────────────────────────────────────────────────────
resource "google_artifact_registry_repository_iam_member" "ci_writer" {
  count = var.ci_sa_email != "" ? 1 : 0

  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${var.ci_sa_email}"
}
