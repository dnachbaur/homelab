output "adguard_home_url" {
  value = "http://${split("/", var.adguard_ip)[0]}:3000"
}
