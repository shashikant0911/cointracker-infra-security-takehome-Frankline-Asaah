resource "google_compute_firewall" "inbound" {
  name        = "allow-${local.proxy_instance_name}"
  network     = module.gcp-network.network_id
  description = "Allow accessing default container port"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  source_ranges = ["10.0.0.0/17"]
}

resource "google_compute_firewall" "ssh_rule" {
  name    = "allow-ssh-${local.proxy_instance_name}"
  network = module.gcp-network.network_id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["10.0.0.0/17"] # change it with the ip you want to give access to
}
