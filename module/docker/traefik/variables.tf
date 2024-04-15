variable "traefik_image_name" {
  type    = string
  default = "traefik:latest"
}

variable "traefik_name" {
  type    = string
  default = "traefik"
}

variable "network_name" {
  type    = string
  default = "docknet"
}