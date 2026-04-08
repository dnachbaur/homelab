output "adguard_home_ip" {
  value = module.adguard_home.adguard_home_ip
}

output "adguard_home_url" {
  value = "http://${module.adguard_home.adguard_home_ip}:3000"
}

output "adguard_ssh_private_key" {
  value     = module.adguard_home.adguard_ssh_private_key
  sensitive = true
}
