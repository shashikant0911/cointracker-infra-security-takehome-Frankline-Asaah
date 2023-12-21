resource "google_compute_firewall" "allow_local_trafic_rule" {
  project = var.project.id
  name    = "allow-local-trafic-rule-gke"
  network = module.gcp-network.network_name

  allow {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/17"]
}

resource "google_compute_firewall" "allow_google_ssh_rule" {
  project = var.project.id
  name    = "allow-google-ssh-gke"
  network = module.gcp-network.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["10.0.0.0/17"]
}

resource "google_compute_firewall" "allow_google_database_rule" {
  name    = var.project.id
  network = module.gcp-network.network_name
  project = "assignment-408612"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  source_ranges = ["10.0.0.0/17"]
}
