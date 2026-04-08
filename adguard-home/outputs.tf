output "adguard_home_ip" {
  value = split("/", var.adguard_ip)[0]
}

output "adguard_ssh_private_key" {
  value     = tls_private_key.adguard_ssh.private_key_pem
  sensitive = true
}
