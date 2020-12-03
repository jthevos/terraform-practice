# resource types must be one of the following: Bucket Database Domain DomainRecord Droplet Firewall FloatingIp Image Kubernetes LoadBalancer MarketplaceApp Saas Volume

resource "digitalocean_project" "JGS-PROD2" {
    name = "JGS-PROD2"
    description = "The Production environment for JG Studios"
    purpose = "Web Application"
    environment = "Production"
    resources = [digitalocean_droplet.jgs_web[0].urn,
                digitalocean_droplet.jgs_web[1].urn,
                digitalocean_loadbalancer.jgs_web.urn,
                #digitalocean_vpc.jgs_web.urn,
                digitalocean_droplet.bastion.urn,
                digitalocean_spaces_bucket.jgs-space-prod.urn
                ]
}

resource "digitalocean_droplet" "jgs_web" {
    count = var.droplet_count

    image = var.image

    name = "web-${var.name}-${var.region}-${count.index + 1}"

    region = var.region

    size = var.droplet_size

    ssh_keys = [data.digitalocean_ssh_key.jgstudios.id]

    vpc_uuid = digitalocean_vpc.jgs_web.id

    tags = ["${var.name}-webserver"]

    user_data = <<EOF
    #cloud-config
    packages:
        - nginx
        - postgresql
        - postgresql-contrib
    runcmd:
        - [sh, -xc, "echo '<h1>web-${var.region}-${count.index + 1}</h1>' >> /var/www/html/index.html"]
    EOF

    // do not tear down existing infrastructure unless the new spin up works
    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_certificate" "jgs_web" {
    name = "${var.name}-certificate"
    type = "lets_encrypt"
    domains = ["${var.subdomain}.${data.digitalocean_domain.jgs_web.name}"]

    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_loadbalancer" "jgs_web" {
    name = "web-lb-${var.region}"
    region = var.region
    droplet_ids = digitalocean_droplet.jgs_web.*.id

    vpc_uuid = digitalocean_vpc.jgs_web.id

    redirect_http_to_https = true

    forwarding_rule {
        entry_port = 443
        entry_protocol = "https"

        target_port = 80
        target_protocol = "http"

        certificate_id = digitalocean_certificate.jgs_web.id

    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_firewall" "jgs_web" {
    name = "${var.name}-only-vpc-traffic"

    droplet_ids = digitalocean_droplet.jgs_web.*.id

    inbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.jgs_web.ip_range]
    }

    inbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.jgs_web.ip_range]
    }

    inbound_rule {
        protocol = "icmp"
        source_addresses = [digitalocean_vpc.jgs_web.ip_range]
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.jgs_web.ip_range]
    }

    outbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.jgs_web.ip_range]
    }

    outbound_rule {
        protocol = "icmp"
        destination_addresses = [digitalocean_vpc.jgs_web.ip_range]
    }

    # HTTP
    outbound_rule {
        protocol = "tcp"
        port_range = "80"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    # HTTPS
    outbound_rule {
        protocol = "tcp"
        port_range = "443"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    # DNS
    outbound_rule {
        protocol = "udp"
        port_range = "53"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    # PING
    outbound_rule {
        protocol = "icmp"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

}

resource "digitalocean_record" "jgs_web" {
    domain = data.digitalocean_domain.jgs_web.name

    type = "A"

    name = var.subdomain

    value =digitalocean_loadbalancer.jgs_web.ip

    ttl = 300
}

// note that space names cannot have _
resource "digitalocean_spaces_bucket" "jgs-space-prod" {
    name   = "jgs-space-prod"
    region = var.region

    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["GET"]
        allowed_origins = ["https://${var.subdomain}.${data.digitalocean_domain.jgs_web.name}"]
        max_age_seconds = 3000
    }

    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["PUT", "POST", "DELETE"]
        allowed_origins = ["https://${var.subdomain}.${data.digitalocean_domain.jgs_web.name}"]
        max_age_seconds = 3000
    }
}
