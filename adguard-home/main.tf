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
  start_on_boot  = true
  started        = true
  timeout_create = 18000
  timeout_update = 18000
  timeout_clone  = 18000
  timeout_delete = 18000

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

# Write SSH key to temp file and run Ansible
resource "null_resource" "provision_with_ansible" {
  depends_on = [proxmox_virtual_environment_container.adguard_home]

  triggers = {
    ansible_playbook_hash = filemd5("${path.module}/../ansible/playbook.yml")
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      keyfile=$(mktemp)
      trap "rm -f $keyfile" EXIT
      cat > $keyfile <<'KEY'
${tls_private_key.adguard_ssh.private_key_pem}
KEY
      chmod 600 $keyfile
      sleep 10
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        --ssh-extra-args='-o ConnectTimeout=10 -o ConnectionAttempts=3' \
        -i '${split("/", var.adguard_ip)[0]},' \
        -u root \
        --private-key $keyfile \
        ${path.module}/../ansible/playbook.yml
    EOT
  }
}
