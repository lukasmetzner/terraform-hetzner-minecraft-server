# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_firewall" "minecraft-server-firewall" {
  name = "minecraft-server-firewall"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "25565"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "25565"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_server" "minecraft-terraform" {
  name         = "minecraft-terraform"
  server_type  = "cpx21"
  image        = "ubuntu-22.04"
  location     = "fsn1"
  ssh_keys     = [var.ssh_key_id]
  firewall_ids = [hcloud_firewall.minecraft-server-firewall.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  connection {
    user        = "root"
    type        = "ssh"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.ipv4_address
  }

  provisioner "file" {
    source      = "./files/minecraft.service"
    destination = "/etc/systemd/system/minecraft.service"
  }

  provisioner "file" {
    source      = "./files/server.properties"
    destination = "/root/server.properties"
  }

  provisioner "remote-exec" {
    inline = [
      "apt update && apt install -y openjdk-17-jre",
      "wget https://github.com/itzg/rcon-cli/releases/download/1.6.0/rcon-cli_1.6.0_linux_amd64.tar.gz",
      "tar xvf rcon-cli_1.6.0_linux_amd64.tar.gz",
      "mv rcon-cli /usr/local/bin",
      "mkdir -p /root/minecraft",
      "cd /root/minecraft",
      "mv /root/server.properties /root/minecraft/server.properties",
      "echo eula=true > eula.txt",
      "wget https://piston-data.mojang.com/v1/objects/c9df48efed58511cdd0213c56b9013a7b5c9ac1f/server.jar",
      "systemctl daemon-reload",
      "systemctl enable minecraft",
      "systemctl start minecraft",
    ]
  }

  provisioner "local-exec" {
    command = "echo ${self.ipv4_address} > minecraft-server-ip.txt"
  }
}
