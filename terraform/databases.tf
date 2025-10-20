# PostgreSQL instance
resource "google_sql_database_instance" "postgres" {
  name             = "${var.project_name}-postgres"
  database_version = "POSTGRES_13"
  region           = var.region

  settings {
    tier = var.db_tier
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
    
    backup_configuration {
      enabled = true
      start_time = "02:00"
    }
  }

  deletion_protection = false  # Set to true for production
}

# Create order database
resource "google_sql_database" "order_db" {
  name     = "order_db"
  instance = google_sql_database_instance.postgres.name
}

# Create delivery database
resource "google_sql_database" "delivery_db" {
  name     = "delivery_db"
  instance = google_sql_database_instance.postgres.name
}

# Create inventory database
resource "google_sql_database" "inventory_db" {
  name     = "inventory_db"
  instance = google_sql_database_instance.postgres.name
}

# Create database user for order service
resource "google_sql_user" "order_user" {
  name     = "order_user"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password # In production, use a more secure method
}

# Create database user for delivery service
resource "google_sql_user" "delivery_user" {
  name     = "delivery_user"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password # In production, use a more secure method
}

# Create database user for inventory service
resource "google_sql_user" "inventory_user" {
  name     = "inventory_user"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password # In production, use a more secure method
}

# Redis instance
resource "google_redis_instance" "cache" {
  name           = "${var.project_name}-redis"
  tier           = var.redis_tier
  memory_size_gb = var.redis_memory_size_gb
  region         = var.region
  
  authorized_network = google_compute_network.vpc.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
}