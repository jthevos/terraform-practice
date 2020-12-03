terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "1.22.2"
    }
  }
}

provider digitalocean {
    token = var.do_token
    spaces_access_id  = var.access_id
    spaces_secret_key = var.secret_key
}
