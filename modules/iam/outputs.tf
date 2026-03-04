# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# IAM MODULE — Outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "gsa_email" {
  description = "Email of the workload Google Service Account."
  value       = google_service_account.workload.email
}

output "gsa_name" {
  description = "Fully-qualified name of the workload GSA."
  value       = google_service_account.workload.name
}

output "ksa_name" {
  description = "Name of the Kubernetes Service Account."
  value       = kubernetes_service_account.workload.metadata[0].name
}
