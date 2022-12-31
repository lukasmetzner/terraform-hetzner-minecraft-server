# Terraform - Hetzner Minecraft Server

## Description
- Spawns a Hetzner CPX21 server with an Ubuntu 22.04 image
- Creates a Hetzner firewall for the server with the open ports 22 (TCP), ICMP, 25565 (TCP/UDP)
- RCON server is activated but not available from the outside, which is why only a basic password is setup

## Setup
- Install Terraform
- In the main.tf adapt the following settings to your own preference: `private_key`, `name`, `server_type`, `location`
- After the setup you will find the ip in a file called: `minecraft-server-ip.txt`
- Create a `secret.tfvars` file:
```
hcloud_token = "" # Hetzner Cloud token
ssh_key_id = "" # ID/Name of the ssh key on your Hetzner account
```
```
terraform init
terraform apply -var-file="./secret.tfvars"
terraform destroy -var-file="./secret.tfvars"
```