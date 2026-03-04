# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NETWORKING MODULE — Outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "network_id" {
  description = "Self-link of the VPC network."
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "Name of the VPC network."
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "Self-link of the private subnet."
  value       = google_compute_subnetwork.private.id
}

output "subnet_name" {
  description = "Name of the private subnet."
  value       = google_compute_subnetwork.private.name
}

output "pods_range_name" {
  description = "Name of the secondary IP range for pods."
  value       = google_compute_subnetwork.private.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "Name of the secondary IP range for services."
  value       = google_compute_subnetwork.private.secondary_ip_range[1].range_name
}

output "router_name" {
  description = "Name of the Cloud Router."
  value       = google_compute_router.router.name
}

output "nat_name" {
  description = "Name of the Cloud NAT gateway."
  value       = google_compute_router_nat.nat.name
}
