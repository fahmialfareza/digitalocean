provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {
  description = "DigitalOcean API token"
}

variable "project_name" {
  default = "fahmialfareza"
}

# Create Container Registry
resource "digitalocean_container_registry" "registry" {
  name                   = var.project_name
  region                 = "sgp1"
  subscription_tier_slug = "starter"
}

output "container_registry_info" {
  value = {
    url      = digitalocean_container_registry.registry.endpoint
    username = digitalocean_container_registry.registry.docker_username
    password = digitalocean_container_registry.registry.docker_password
  }
}

# Create Redis Database Cluster
resource "digitalocean_database_cluster" "redis" {
  name     = "${var.project_name}-redis"
  engine   = "redis"
  version  = "7"
  region   = "sgp1"
  size     = "db-s-1vcpu-1gb"
  vpc_uuid = digitalocean_vpc.default.id
}

resource "digitalocean_vpc" "default" {
  name   = "default-sgp1"
  region = "sgp1"
}

output "redis_database_info" {
  value = {
    private_uri = digitalocean_database_cluster.redis.private_uri
  }
}

# Create Kubernetes Cluster
resource "digitalocean_kubernetes_cluster" "k8s" {
  name         = "${var.project_name}-kubernetes-cluster"
  region       = "sgp1"
  version      = "latest"
  auto_upgrade = true

  node_pool {
    name       = "worker-pool"
    size       = "s-1vcpu-2gb"
    min_nodes  = 1
    max_nodes  = 2
    auto_scale = true
  }

  vpc_uuid = digitalocean_vpc.default.id
}

output "kubernetes_cluster_name" {
  value = digitalocean_kubernetes_cluster.k8s.name
}
