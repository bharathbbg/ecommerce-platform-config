# MongoDB Atlas configuration
# For simplicity, we'll use a VM with MongoDB installed
# In production, use MongoDB Atlas or a managed service

resource "google_compute_instance" "mongodb" {
  name         = "${var.project_name}-mongodb"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
      size  = 50
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y gnupg
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
    apt-get update
    apt-get install -y mongodb-org
    systemctl start mongod
    systemctl enable mongod
    
    # Create inventory database
    mongo --eval 'db = db.getSiblingDB("inventory_db"); db.createUser({user: "inventory_user", pwd: "${var.db_password}", roles: [{role: "readWrite", db: "inventory_db"}]})'
  EOF

  # In production, use proper security measures
  tags = ["mongodb"]

  service_account {
    scopes = ["cloud-platform"]
  }
}

# Firewall rule to allow internal MongoDB access
resource "google_compute_firewall" "mongodb" {
  name    = "${var.project_name}-mongodb-firewall"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_ranges = [google_compute_subnetwork.subnet.ip_cidr_range]
  target_tags   = ["mongodb"]
}