# GKE cluster resources
resource "google_container_cluster" "primary" {
  name     = "${var.project_name}-gke"
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.gke_subnet.name  # Changed from subnet to gke_subnet

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"      # Match the name in network.tf
    services_secondary_range_name = "gke-services"  # Match the name in network.tf
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.project_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    preemptible  = true
    machine_type = var.gke_machine_type

    # REDUCE THIS VALUE - Currently requesting 900GB total (3 nodes × 300GB each)
    # Change to 100GB per node = 300GB total (well within 500GB quota)
    disk_size_gb = 100  # Change from 300 to 100
    disk_type    = "pd-standard"  # Or change from "pd-ssd" to "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    labels = {
      env = var.project_id
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Enable Workload Identity on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}