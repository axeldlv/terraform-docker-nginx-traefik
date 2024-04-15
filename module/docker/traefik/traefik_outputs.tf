output "traefik_name" {
  value = docker_container.traefik.name
}

output "traefik_ip" {
  value = docker_container.traefik.network_data[0].ip_address
}