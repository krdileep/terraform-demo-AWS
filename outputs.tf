output "my-server-public-ip" {
  value = module.webserver.server.public_ip
}