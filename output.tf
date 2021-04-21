output "outputed_from_webserver_module" {
  value       = module.myapp-webserver.instance.public_ip
}
