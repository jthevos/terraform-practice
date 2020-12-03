resource "digitalocean_droplet" "bastion" {
    image = var.image

    name = "bastion-${var.name}-${var.region}"

    region = var.region

    size = "s-1vcpu-1gb"

    ssh_keys = [data.digitalocean_ssh_key.jgstudios.id]

    vpc_uuid = digitalocean_vpc.jgs_web.id

    tags = ["${var.name}-webserver"]

    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_record" "bastion" {
    domain = data.digitalocean_domain.jgs_web.name

    type = "A"

    name = "bastion-${var.name}-${var.region}"

    value = digitalocean_droplet.bastion.ipv4_address

    ttl = 300
}

resource "digitalocean_firewall" "bastion" {
    name = "${var.name}-only-ssh-bastion"

    droplet_ids = [digitalocean_droplet.bastion.id]

    inbound_rule {
        protocol = "tcp"
        port_range = "22"
        source_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol = "icmp"
        destination_addresses = [digitalocean_vpc.jgs_web.ip_range]
    }
}
