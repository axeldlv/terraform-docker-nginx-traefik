output "nginx_ip" {
  value = module.docker-nginx.nginx_ip
}

output "nginx_name" {
  value = module.docker-nginx.nginx_name
}

output "traefik_name" {
  value = module.docker-traefik.traefik_name
}

output "traefik_ip" {
  value = module.docker-traefik.traefik_ip
}