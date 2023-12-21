provider "google" {
  #credentials = file("./assignment-408612-e767fff0f816.json")
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
