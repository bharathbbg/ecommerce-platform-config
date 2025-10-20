# E-Commerce Platform Terraform Infrastructure

This repository contains Terraform code to deploy the e-commerce microservices platform to Google Cloud Platform (GCP).

## Architecture

- Google Kubernetes Engine (GKE) for container orchestration
- Cloud SQL for PostgreSQL databases
- MongoDB Atlas for MongoDB database (via GCP Marketplace)
- Memorystore for Redis caching
- Cloud Load Balancing for traffic management
- Cloud IAM for security

## Prerequisites

- Terraform 1.0+
- Google Cloud SDK
- GCP project with billing enabled
- Appropriate permissions to create resources

## Getting Started

1. Set up authentication:

```bash
gcloud auth application-default login
```

2. Initialize Terraform:

```bash
terraform init
```

3. Plan the deployment:

```bash
terraform plan -var-file=staging.tfvars
```

4. Apply the configuration:

```bash
terraform apply -var-file=staging.tfvars
```

## Environment Configuration

Environment-specific configurations are stored in `.tfvars` files:

- `staging.tfvars`: Staging environment configuration
- `production.tfvars`: Production environment configuration (when ready)

## Modules

- `gke`: Creates and configures GKE cluster
- `sql`: Sets up PostgreSQL databases
- `mongodb`: Provisions MongoDB instance
- `redis`: Sets up Redis cache
- `networking`: Configures VPC, subnets, and firewall rules

## Usage

After deployment, you can access the services using:

```bash
# Get Kubernetes credentials
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)

# View deployed services
kubectl get services
```