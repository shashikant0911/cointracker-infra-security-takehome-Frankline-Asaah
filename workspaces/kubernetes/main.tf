module "gcp-network" {
  source  = "terraform-google-modules/network/google"
  version = ">= 4.0.1"

  project_id   = var.project.id
  network_name = var.network_name

  subnets = [
    {
      subnet_name           = var.subnetwork.name
      subnet_ip             = var.subnetwork.cidr
      subnet_region         = var.project.region
      subnet_private_access = true
    },
  ]

  secondary_ranges = {
    (var.subnetwork.name) = [
      {
        range_name    = var.ip_range_pods.name
        ip_cidr_range = var.ip_range_pods.cidr
      },
      {
        range_name    = var.ip_range_services.name
        ip_cidr_range = var.ip_range_services.cidr
      },
    ]
  }
}

module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 2.0"
  project_id    = var.project.id
  region        = var.project.region
  router        = var.router_name
  network       = module.gcp-network.network_name
  create_router = true
}

/*****************************************
  GKE
 *****************************************/
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "25.0.0"

  # required variables
  project_id        = var.project.id
  name              = var.cluster_name
  region            = var.project.region
  zones             = [var.project.zone_primary, var.project.zone_secondary]
  network           = module.gcp-network.network_name
  subnetwork        = module.gcp-network.subnets_names[0]
  ip_range_pods     = var.ip_range_pods.name
  ip_range_services = var.ip_range_services.name

  # optional variables
  kubernetes_version = "1.27.3-gke.100"
  regional           = true

  create_service_account = false
  service_account        = google_service_account.gke_service_account.email

  enable_private_endpoint   = false
  enable_private_nodes      = true
  default_max_pods_per_node = 20
  remove_default_node_pool  = true

  master_ipv4_cidr_block = "10.100.0.0/28"

  master_authorized_networks = [{
    cidr_block   = "0.0.0.0/0"
    display_name = "all"
  }]

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = var.machine_type
      min_count          = var.min_count
      max_count          = var.max_count
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      auto_repair        = true
      auto_upgrade       = true
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []
    default-node-pool = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  node_pools_labels = {
    all = {}
    default-node-pool = {
      default-node-pool = true,
    }
  }

  node_pools_tags = {
    all = []
    default-node-pool = [
      "default-node-pool",
    ]
  }
}

data "google_secret_manager_secret_version" "my-secret" {
  provider = google-beta

  secret  = "kubernetes-secret"
  version = "1"
}

output "secret" {
  sensitive = true
  value = data.google_secret_manager_secret_version.my-secret.secret_data
}
