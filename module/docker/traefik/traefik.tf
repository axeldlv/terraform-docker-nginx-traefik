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

data "docker_registry_image" "traefik" {
  name = "traefik:latest"
}

resource "docker_image" "traefik" {
  name          = var.traefik_image_name
  pull_triggers = [data.docker_registry_image.traefik.sha256_digest]
  keep_locally  = false
}

resource "docker_container" "traefik" {
  name  = var.traefik_name
  image = docker_image.traefik.image_id

  restart               = "unless-stopped"
  destroy_grace_seconds = 30
  must_run              = true
  memory                = 256
  memory_swap           = 512

  networks_advanced {
    name    = var.network_name
    aliases = [var.network_name]
  }

  command = [
    "--entrypoints.web.address=:86",
    # "--entrypoints.web.http.redirections.entryPoint.to=websecure",
    # "--entrypoints.web.http.redirections.entryPoint.scheme=https",
    # "--entrypoints.web.http.redirections.entrypoint.permanent=true",
    # "--entrypoints.websecure.address=:443",
    "--log.level=DEBUG",
    "--entrypoints.websecure.http.tls=false",
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    "--api"
  ]

  volumes {
    #volume_name    = "traefik_config"
    host_path      = "/Docker/module/docker/traefik/configs"
    container_path = "/etc/traefik"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 443
    external = 443
  }

  labels {
    # You can tell Traefik to consider (or not) the container by setting traefik.enable to true or false.
    # This option overrides the value of exposedByDefault.
    label = "traefik.enable"
    value = true
  }

  labels {
    # Overrides the default docker network to use for connections to the container.
    label = "traefik.docker.network"
    value = var.network_name
  }
}