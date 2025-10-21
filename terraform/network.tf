# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "ecommerce-platform-vpc"
  auto_create_subnetworks = false
}

# Subnet for GKE
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# Subnet for other resources
resource "google_compute_subnetwork" "app_subnet" {
  name          = "app-subnet"
  ip_cidr_range = "10.3.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Enable Service Networking API
resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"

  disable_on_destroy         = false
  disable_dependent_services = false
}

# Enable Redis API
resource "google_project_service" "redis" {
  project = var.project_id
  service = "redis.googleapis.com"

  disable_on_destroy         = false
  disable_dependent_services = false
}

# Reserve IP range for private services (Cloud SQL, Redis, etc.)
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id

  depends_on = [google_project_service.servicenetworking]
}

# Create private VPC connection (enables private service access)
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [
    google_project_service.servicenetworking,
    google_compute_global_address.private_ip_address
  ]
}

# Firewall rule for internal communication
resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.name

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

  source_ranges = ["10.0.0.0/8"]
}

# Firewall rule for SSH
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}