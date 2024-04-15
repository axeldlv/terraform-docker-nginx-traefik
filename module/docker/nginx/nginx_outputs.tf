output "nginx_ip" {
  value = docker_container.nginx.network_data[0].ip_address
}

output "nginx_name" {
  value = docker_container.nginx.name
}