variable "nginx_name" {
  type    = string
  default = "nginx"
}

variable "nginx_image_name" {
  type    = string
  default = "nginx:latest"
}

variable "network_name" {
  type    = string
  default = "docknet"
}