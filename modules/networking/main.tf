# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NETWORKING MODULE — VPC, Subnet, Cloud Router, Cloud NAT, Firewall
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Creates an isolated, non-default VPC with a single private subnet that
# carries secondary IP ranges for GKE pods and services. A Cloud Router
# and Cloud NAT gateway provide egress-only internet access so that private
# nodes can pull container images without exposing a public IP.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ──────────────────────────────────────────────────────────────────────────────
# VPC Network
# ──────────────────────────────────────────────────────────────────────────────
resource "google_compute_network" "vpc" {
  name                    = "vanguard-vpc-${var.environment}"
  project                 = var.project_id
  auto_create_subnetworks = false # Custom mode — no default subnets
  routing_mode            = "REGIONAL"
  description             = "Custom VPC for GKE Vanguard (${var.environment})"
}

# ──────────────────────────────────────────────────────────────────────────────
# Private Subnet with Secondary Ranges for GKE
# ──────────────────────────────────────────────────────────────────────────────
resource "google_compute_subnetwork" "private" {
  name                     = "vanguard-private-${var.environment}"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true # Allows private VMs to reach Google APIs

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# Cloud Router
# ──────────────────────────────────────────────────────────────────────────────
resource "google_compute_router" "router" {
  name    = "vanguard-router-${var.environment}"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id

  bgp {
    asn = 64514
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# Cloud NAT — egress-only internet for private nodes
# ──────────────────────────────────────────────────────────────────────────────
resource "google_compute_router_nat" "nat" {
  name                               = "vanguard-nat-${var.environment}"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# Firewall Rules
# ──────────────────────────────────────────────────────────────────────────────

# Allow internal communication within the VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "vanguard-allow-internal-${var.environment}"
  project = var.project_id
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr, var.pods_cidr, var.services_cidr]
  priority      = 1000
  description   = "Allow all internal traffic within VPC subnets."
}

# Allow SSH via Identity-Aware Proxy (IAP) for bastion access
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "vanguard-allow-iap-ssh-${var.environment}"
  project = var.project_id
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP's well-known IP range
  source_ranges = ["35.235.240.0/20"]
  priority      = 900
  description   = "Allow SSH from IAP tunnel IP range for secure bastion access."
}
