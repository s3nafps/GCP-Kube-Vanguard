# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# IAM MODULE — Workload Identity Binding (KSA ↔ GSA)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Creates a Google Service Account (GSA) and binds it to a Kubernetes Service
# Account (KSA) via GKE Workload Identity. This eliminates the need for
# exported JSON keys and provides per-pod IAM identity scoping.
#
# How it works:
#   1. A GSA is created and granted the specified IAM roles.
#   2. The GSA's IAM policy allows the KSA to impersonate it via
#      `roles/iam.workloadIdentityUser`.
#   3. A KSA is created in the target namespace with an annotation that
#      points to the GSA email.
#   4. Any pod running as this KSA transparently receives the GSA's
#      credentials via the GKE metadata server.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ──────────────────────────────────────────────────────────────────────────────
# Google Service Account (GSA) for Workloads
# ──────────────────────────────────────────────────────────────────────────────
resource "google_service_account" "workload" {
  account_id   = "workload-${var.ksa_name}-${var.environment}"
  display_name = "Workload Identity GSA for ${var.ksa_name} (${var.environment})"
  project      = var.project_id
  description  = "GSA bound to KSA '${var.ksa_name}' in namespace '${var.namespace}' via Workload Identity."
}

# ──────────────────────────────────────────────────────────────────────────────
# Grant IAM roles to the GSA
# ──────────────────────────────────────────────────────────────────────────────
resource "google_project_iam_member" "workload_roles" {
  for_each = toset(var.gsa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.workload.email}"
}

# ──────────────────────────────────────────────────────────────────────────────
# Workload Identity Binding: Allow the KSA to impersonate the GSA
# ──────────────────────────────────────────────────────────────────────────────
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.workload.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.ksa_name}]"
}

# ──────────────────────────────────────────────────────────────────────────────
# Kubernetes Service Account (KSA) with Workload Identity annotation
# ──────────────────────────────────────────────────────────────────────────────
resource "kubernetes_service_account" "workload" {
  metadata {
    name      = var.ksa_name
    namespace = var.namespace

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.workload.email
    }

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }

  automount_service_account_token = true
}
