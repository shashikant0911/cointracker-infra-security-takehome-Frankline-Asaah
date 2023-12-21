/*****************************************
  IP
 *****************************************/

# Reserve a static internal IP address for Cloud SQL:
resource "google_compute_global_address" "private_ip_address" {
  project  = var.project.id
  provider = google-beta
  name     = "${var.project.id}-cloudsql-private-ip"

  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.gcp-network.network_id
}

/*****************************************
  Database Instance
 *****************************************/

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  project	   = var.project.id
  provider         = google-beta
  database_version = var.db_version
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  name             = "${var.cloudsql_instance_name}-${random_id.db_name_suffix.hex}"
  region           = var.project.region

  lifecycle {
    prevent_destroy = false
  }
  deletion_protection = false
  settings {
    deletion_protection_enabled = false
    tier                        = var.machine_type

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = module.gcp-network.network_id
      enable_private_path_for_google_cloud_services = true
    }

    database_flags {
        name  = "max_connections"
        value = "1000"
      }

  }
}

/*****************************************
  DB and USERs
 *****************************************/
resource "google_sql_database" "app" {
  project  = var.project.id
  name     = data.google_secret_manager_secret_version.db-secret_v2.secret_data
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "app_user" {
  project  = var.project.id
  name     = data.google_secret_manager_secret_version.db-secret_v3.secret_data
  instance = google_sql_database_instance.instance.name
  password = data.google_secret_manager_secret_version.db-secret_v4.secret_data
}

data "google_secret_manager_secret_version" "my-secret" {
  provider = google-beta

  secret  = "kubernetes-secret"
  version = "1"
}

data "google_secret_manager_secret_version" "db_secret_v2" {
  provider = google-beta
  secret   = "db-secret"
  version  = "2"
}

data "google_secret_manager_secret_version" "db_secret_v3" {
  provider = google-beta
  secret   = "db-secret"
  version  = "3" 
}

data "google_secret_manager_secret_version" "db_secret_v4" {
  provider = google-beta
  secret   = "db-secret"
  version  = "4"
}
