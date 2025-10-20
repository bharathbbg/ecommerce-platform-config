# Output values for easy reference
output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "postgres_instance_connection_name" {
  value       = google_sql_database_instance.postgres.connection_name
  description = "PostgreSQL instance connection name"
}

output "postgres_instance_ip" {
  value       = google_sql_database_instance.postgres.private_ip_address
  description = "PostgreSQL instance IP address"
}

output "mongodb_instance_ip" {
  value       = google_compute_instance.mongodb.network_interface[0].network_ip
  description = "MongoDB instance IP address"
}

output "redis_instance_host" {
  value       = google_redis_instance.cache.host
  description = "Redis instance host"
}