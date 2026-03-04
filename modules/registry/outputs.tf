# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# REGISTRY MODULE — Outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "repository_id" {
  description = "The Artifact Registry repository resource ID."
  value       = google_artifact_registry_repository.docker.id
}

output "repository_url" {
  description = "Full Docker registry URL (region-docker.pkg.dev/project/repo)."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}"
}

output "repository_name" {
  description = "Name of the Artifact Registry repository."
  value       = google_artifact_registry_repository.docker.name
}
