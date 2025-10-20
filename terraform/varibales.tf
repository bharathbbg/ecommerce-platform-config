variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "ecommerce-platform-475712"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "ecommerce-platform"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-south1-a"
}

variable "gke_num_nodes" {
  description = "Number of GKE nodes"
  type        = number
  default     = 3
}

variable "gke_machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-standard-2"
}

variable "db_tier" {
  description = "Database machine tier"
  type        = string
  default     = "db-g1-small"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "redis_tier" {
  description = "Redis tier"
  type        = string
  default     = "STANDARD_HA"
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB"
  type        = number
  default     = 1
}