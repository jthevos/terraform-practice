resource "digitalocean_vpc" "jgs_web" {
    name = "jgstudios-vpc"
    region = var.region

    ip_range = "192.168.44.0/24"
}
