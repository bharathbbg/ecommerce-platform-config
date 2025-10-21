# MongoDB Atlas configuration
# For simplicity, we'll use a VM with MongoDB installed
# In production, use MongoDB Atlas or a managed service

resource "google_compute_instance" "mongodb" {
  name         = "${var.project_name}-mongodb"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 50
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.app_subnet.id  # Changed from subnet to app_subnet
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y gnupg curl
    curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    apt-get update
    apt-get install -y mongodb-org
    systemctl start mongod
    systemctl enable mongod
    
    # Wait for MongoDB to start
    sleep 10
    
    # Create inventory database and user
    mongosh --eval 'use inventory_db; db.createUser({user: "inventory_user", pwd: "${var.db_password}", roles: [{role: "readWrite", db: "inventory_db"}]})'
  EOF

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

  source_ranges = [google_compute_subnetwork.app_subnet.ip_cidr_range]  # Changed from subnet to app_subnet
  target_tags   = ["mongodb"]
}