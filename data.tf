data "digitalocean_ssh_key" "jgstudios" {
  name = var.ssh_key
}

data "digitalocean_domain" "jgs_web" {
    name = var.domain_name
}

//data "digitalocean_ssh_key" "jgstudios" {
//  name = "jgstudios"
//}
