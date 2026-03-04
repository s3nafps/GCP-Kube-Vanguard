# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ROOT MODULE — Orchestrates all child modules
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ──────────────────────────────────────────────────────────────────────────────
# 1. NETWORKING
# ──────────────────────────────────────────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
}

# ──────────────────────────────────────────────────────────────────────────────
# 2. GKE CLUSTER
# ──────────────────────────────────────────────────────────────────────────────
module "cluster" {
  source = "./modules/cluster"

  project_id          = var.project_id
  region              = var.region
  zone                = var.zone
  environment         = var.environment
  cluster_name        = var.cluster_name
  network_id          = module.networking.network_id
  subnet_id           = module.networking.subnet_id
  pods_range_name     = module.networking.pods_range_name
  services_range_name = module.networking.services_range_name
  master_cidr         = var.master_cidr
  authorized_networks = var.authorized_networks
  release_channel     = var.release_channel
  machine_type        = var.machine_type
  disk_size_gb        = var.disk_size_gb
  min_node_count      = var.min_node_count
  max_node_count      = var.max_node_count
}

# ──────────────────────────────────────────────────────────────────────────────
# 3. IAM — Workload Identity Binding (KSA ↔ GSA)
# ──────────────────────────────────────────────────────────────────────────────
module "iam" {
  source = "./modules/iam"

  project_id   = var.project_id
  cluster_name = module.cluster.cluster_name
  namespace    = var.workload_identity_namespace
  ksa_name     = var.workload_identity_ksa_name
  gsa_roles    = var.workload_gsa_roles
  environment  = var.environment
}

# ──────────────────────────────────────────────────────────────────────────────
# 4. ARTIFACT REGISTRY
# ──────────────────────────────────────────────────────────────────────────────
module "registry" {
  source = "./modules/registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = var.gar_repository_id
  environment   = var.environment
}
