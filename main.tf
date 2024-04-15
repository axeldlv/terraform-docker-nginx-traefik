terraform {
  // Need to add explicitly the provider because it is not being picked up by the parent module 
  // It is not from hashicorp/docker as it is used in the parent module
  required_providers {
    docker = {
      version = "~> 3.0.2"
      source  = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "traefik" {
  name   = var.network_name
  driver = "bridge"
}

module "docker-nginx" {
  source = "./module/docker/nginx"

  network_name     = var.network_name
  nginx_name       = var.nginx_name
  nginx_image_name = var.nginx_image_name
}

module "docker-traefik" {
  source = "./module/docker/traefik"

  network_name       = var.network_name
  traefik_name       = var.traefik_name
  traefik_image_name = var.traefik_image_name
}

