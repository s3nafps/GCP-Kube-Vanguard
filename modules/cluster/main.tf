# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CLUSTER MODULE — Private GKE Cluster, Node Pool, Least-Privilege SA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Deploys a private GKE cluster where:
#   • Nodes have NO public IP addresses.
#   • The control-plane endpoint is restricted to authorized networks only.
#   • Workload Identity is enabled at the cluster level.
#   • A dedicated, least-privilege Service Account replaces the default
#     Compute Engine SA on every node.
#   • Shielded Nodes, Dataplane V2, and auto-upgrade/repair are enforced.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ──────────────────────────────────────────────────────────────────────────────
# Least-Privilege Node Service Account
# ──────────────────────────────────────────────────────────────────────────────
resource "google_service_account" "gke_nodes" {
  account_id   = "${var.cluster_name}-nodes-${var.environment}"
  display_name = "GKE Node SA — ${var.cluster_name} (${var.environment})"
  project      = var.project_id
  description  = "Least-privilege SA for GKE node pool. Replaces the default Compute Engine SA."
}

# Grant only the permissions nodes actually need
locals {
  node_sa_roles = [
    "roles/logging.logWriter",                   # Write logs to Cloud Logging
    "roles/monitoring.metricWriter",             # Write metrics to Cloud Monitoring
    "roles/monitoring.viewer",                   # Read monitoring dashboards
    "roles/artifactregistry.reader",             # Pull images from Artifact Registry
    "roles/stackdriver.resourceMetadata.writer", # Write resource metadata
  ]
}

resource "google_project_iam_member" "node_sa_roles" {
  for_each = toset(local.node_sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# ──────────────────────────────────────────────────────────────────────────────
# Private GKE Cluster
# ──────────────────────────────────────────────────────────────────────────────
resource "google_container_cluster" "primary" {
  name     = "${var.cluster_name}-${var.environment}"
  project  = var.project_id
  location = var.zone

  # ── Networking ──────────────────────────────────────────────────────────────
  network    = var.network_id
  subnetwork = var.subnet_id

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # ── Private Cluster Configuration ──────────────────────────────────────────
  private_cluster_config {
    enable_private_nodes    = true  # Nodes get internal IPs only
    enable_private_endpoint = false # Control-plane reachable from authorized CIDRs
    master_ipv4_cidr_block  = var.master_cidr
  }

  # ── Control-Plane Authorized Networks ──────────────────────────────────────
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_networks
      content {
        display_name = cidr_blocks.value.display_name
        cidr_block   = cidr_blocks.value.cidr_block
      }
    }
  }

  # ── Workload Identity ──────────────────────────────────────────────────────
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # ── Dataplane V2 (Cilium-based network policy enforcement) ─────────────────
  datapath_provider = "ADVANCED_DATAPATH"

  # ── Release Channel ────────────────────────────────────────────────────────
  release_channel {
    channel = var.release_channel
  }

  # ── Security Hardening ─────────────────────────────────────────────────────
  enable_shielded_nodes = true
  deletion_protection   = false

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  # ── Remove Default Node Pool (we manage our own below) ─────────────────────
  remove_default_node_pool = true
  initial_node_count       = 1

  # ── Cluster Add-ons ────────────────────────────────────────────────────────
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  # ── Resource Labels ────────────────────────────────────────────────────────
  resource_labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "gcp-kube-vanguard"
  }

  # Ignore changes to initial_node_count after first apply
  lifecycle {
    ignore_changes = [initial_node_count]
  }
}

# ──────────────────────────────────────────────────────────────────────────────
# Managed Node Pool
# ──────────────────────────────────────────────────────────────────────────────
resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.cluster_name}-nodepool-${var.environment}"
  project  = var.project_id
  location = var.zone
  cluster  = google_container_cluster.primary.name

  # ── Autoscaling ────────────────────────────────────────────────────────────
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # ── Node Management ────────────────────────────────────────────────────────
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # ── Node Configuration ─────────────────────────────────────────────────────
  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-standard"
    image_type   = "COS_CONTAINERD"

    # Use the least-privilege SA — NOT the default Compute Engine SA
    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    # Workload Identity metadata server on every node
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded Instance features
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = {
      environment = var.environment
      managed_by  = "terraform"
    }

    tags = ["gke-node", "vanguard-${var.environment}"]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
