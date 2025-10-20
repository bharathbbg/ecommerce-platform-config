# Kubernetes resources - defines what will be deployed to GKE

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

data "google_client_config" "default" {}

# Kubernetes namespace
resource "kubernetes_namespace" "ecommerce" {
  metadata {
    name = var.project_name
  }
}

# ConfigMaps and Secrets would go here for service configurations

# Service deployments would be defined here
# Example:
resource "kubernetes_deployment" "order_service" {
  metadata {
    name      = "order-service"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "order-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "order-service"
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project_id}/order-service:latest"
          name  = "order-service"
          
          env {
            name  = "DB_HOST"
            value = google_sql_database_instance.postgres.private_ip_address
          }
          
          env {
            name  = "DB_NAME"
            value = "order_db"
          }
          
          env {
            name  = "DB_USER"
            value = "order_user"
          }
          
          # In production use secrets
          env {
            name  = "DB_PASSWORD"
            value = var.db_password
          }
          
          env {
            name  = "REDIS_HOST"
            value = google_redis_instance.cache.host
          }
          
          # Additional environment variables...
          
          port {
            container_port = 8080
          }
          
          port {
            container_port = 50051
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "inventory_service" {
  metadata {
    name      = "inventory-service"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "inventory-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "inventory-service"
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project_id}/inventory-service:latest"
          name  = "inventory-service"
          
          env {
            name  = "DB_HOST"
            value = google_sql_database_instance.postgres.private_ip_address
          }
          
          env {
            name  = "DB_NAME"
            value = "inventory_db"
          }
          
          env {
            name  = "DB_USER"
            value = "inventory_user"
          }
          
          # In production use secrets
          env {
            name  = "DB_PASSWORD"
            value = var.db_password
          }
          
          env {
            name  = "REDIS_HOST"
            value = google_redis_instance.cache.host
          }
          
          # Additional environment variables...
          
          port {
            container_port = 8080
          }
          
          port {
            container_port = 50051
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "delivery_service" {
  metadata {
    name      = "delivery-service"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "delivery-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "delivery-service"
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project_id}/delivery-service:latest"
          name  = "delivery-service"
          
          env {
            name  = "DB_HOST"
            value = google_sql_database_instance.postgres.private_ip_address
          }
          
          env {
            name  = "DB_NAME"
            value = "delivery_db"
          }
          
          env {
            name  = "DB_USER"
            value = "delivery_user"
          }
          
          # In production use secrets
          env {
            name  = "DB_PASSWORD"
            value = var.db_password
          }
          
          env {
            name  = "REDIS_HOST"
            value = google_redis_instance.cache.host
          }
          
          # Additional environment variables...
          
          port {
            container_port = 8080
          }
          
          port {
            container_port = 50051
          }
        }
      }
    }
  }
}
