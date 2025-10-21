# Kubernetes namespace - managed by Terraform
resource "kubernetes_namespace" "ecommerce" {
  metadata {
    name = "ecommerce-platform"
  }

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes
  ]
}

# Create secrets for database connections - managed by Terraform
# These secrets will be referenced by the deployments in k8s/*.yaml files
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }

  data = {
    postgres_host     = google_sql_database_instance.postgres.private_ip_address
    postgres_password = var.db_password
    mongodb_host      = google_compute_instance.mongodb.network_interface[0].network_ip
    mongodb_password  = var.db_password
    redis_host        = google_redis_instance.cache.host
  }

  depends_on = [
    google_sql_database_instance.postgres,
    google_compute_instance.mongodb,
    google_redis_instance.cache
  ]

  lifecycle {
    ignore_changes = [data]
  }
}

# Note: Application deployments and services are managed via kubectl
# Apply them separately using:
# kubectl apply -f ../k8s/order-service.yaml
# kubectl apply -f ../k8s/inventory-service.yaml
# kubectl apply -f ../k8s/delivery-service.yaml
