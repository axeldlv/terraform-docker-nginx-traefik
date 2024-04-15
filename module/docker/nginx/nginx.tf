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

data "docker_registry_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_image" "nginx" {
  name          = var.nginx_image_name
  pull_triggers = [data.docker_registry_image.nginx.sha256_digest]
  keep_locally  = false
}

resource "docker_container" "nginx" {
  name  = var.nginx_name
  image = docker_image.nginx.image_id

  restart               = "unless-stopped"
  destroy_grace_seconds = 30
  must_run              = true
  memory                = 256
  memory_swap           = 512

  networks_advanced {
    name    = var.network_name
    aliases = [var.network_name]
  }

  volumes {
    #volume_name    = "nginx_html"
    host_path      = "/Docker/module/docker/nginx/configs/html"
    container_path = "/usr/share/nginx/html"
  }

  volumes {
    #volume_name    = "nginx_config"
    host_path      = "/Docker/module/docker/nginx/configs/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
  }

  env = [
    "PUID=501",
    "PGID=20"
  ]

  ports {
    internal = 80
    external = 90
  }

  labels {
    # You can tell Traefik to consider (or not) the container by setting traefik.enable to true or false.
    # This option overrides the value of exposedByDefault.
    label = "traefik.enable"
    value = true
  }

  labels {
    # traefik.http.routers.my-container.rule=Host(`example.com`)
    label = "traefik.http.routers.${var.nginx_name}.rule"
    value = "PathPrefix(`/test`)"
  }

  labels {
    label = "traefik.http.routers.${var.nginx_name}.entrypoints"
    value = "web"
  }

  labels {
    # Overrides the default docker network to use for connections to the container.
    label = "traefik.docker.network"
    value = var.network_name
  }
}