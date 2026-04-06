resource "tls_private_key" "adguard_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_password" "adguard_root_password" {
  length           = 20
  override_special = "_%@"
  special          = true
}

resource "proxmox_download_file" "debian_13_lxc" {
  content_type = "vztmpl"
  datastore_id = var.adguard_template_datastore
  node_name    = var.proxmox_node_name
  url          = var.adguard_template_url
}

resource "proxmox_virtual_environment_container" "adguard_home" {
  description  = "AdGuard Home LXC managed by OpenTofu"
  node_name    = var.proxmox_node_name
  vm_id        = var.adguard_vmid
  unprivileged = true
  features {
    nesting = false
  }
  start_on_boot = true
  wait_for_ip {
    ipv4 = true
  }

  initialization {
    hostname = var.adguard_hostname

    dns {
      servers = var.adguard_dns_servers
    }

    ip_config {
      ipv4 {
        address = var.adguard_ip
        gateway = var.adguard_gateway
      }
    }

    user_account {
      keys     = [tls_private_key.adguard_ssh.public_key_openssh]
      password = random_password.adguard_root_password.result
    }
  }

  network_interface {
    name = "eth0"
  }

  disk {
    datastore_id = var.adguard_storage
    size         = 8
  }

  operating_system {
    template_file_id = proxmox_download_file.debian_13_lxc.id
    type             = "debian"
  }

  tags = ["adguard", "dns"]
}

resource "null_resource" "install_adguard_home" {
  depends_on = [proxmox_virtual_environment_container.adguard_home]

  triggers = {
    adguard_ip   = var.adguard_ip
    adguard_vmid = var.adguard_vmid
  }

  connection {
    type        = "ssh"
    host        = split("/", var.adguard_ip)[0]
    user        = "root"
    private_key = tls_private_key.adguard_ssh.private_key_pem
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "apt-get install -y curl tar",
      "cd /tmp",
      "curl -LO https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_linux_amd64.tar.gz",
      "tar xzf AdGuardHome_linux_amd64.tar.gz",
      "cd AdGuardHome",
      "./AdGuardHome -s install",
      "systemctl enable AdGuardHome",
      "systemctl start AdGuardHome"
    ]
  }
}
