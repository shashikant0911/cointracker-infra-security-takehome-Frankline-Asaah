provider "google" {
  credentials = data.google_secret_manager_secret_version.my-secret.secret_data
  project = var.project.name
  region  = var.project.region
  zone    = var.project.zone_primary
}

provider "google-beta" {
  project = var.project.id
  region  = var.project.region
  zone    = var.project.zone_primary
}
