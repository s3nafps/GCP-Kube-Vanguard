# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ROOT OUTPUTS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ── Networking ────────────────────────────────────────────────────────────────
output "network_name" {
  description = "The name of the VPC network."
  value       = module.networking.network_name
}

output "subnet_name" {
  description = "The name of the private subnet."
  value       = module.networking.subnet_name
}

# ── GKE Cluster ───────────────────────────────────────────────────────────────
output "cluster_name" {
  description = "GKE cluster name."
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "GKE cluster control-plane endpoint (private)."
  value       = module.cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded CA certificate for the GKE cluster."
  value       = module.cluster.ca_certificate
  sensitive   = true
}

output "node_service_account_email" {
  description = "Email of the least-privilege SA used by GKE nodes."
  value       = module.cluster.node_sa_email
}

# ── IAM / Workload Identity ──────────────────────────────────────────────────
output "workload_gsa_email" {
  description = "Email of the Google Service Account bound to the Kubernetes SA."
  value       = module.iam.gsa_email
}

output "workload_ksa_name" {
  description = "Name of the Kubernetes Service Account with Workload Identity."
  value       = module.iam.ksa_name
}

# ── Artifact Registry ────────────────────────────────────────────────────────
output "gar_repository_url" {
  description = "Full URL of the Artifact Registry Docker repository."
  value       = module.registry.repository_url
}

output "gar_repository_id" {
  description = "The Artifact Registry repository resource ID."
  value       = module.registry.repository_id
}
