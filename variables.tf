variable do_token {}
variable "ssh_key" {}

variable region {
    type = string
    default = "nyc3"
}

variable droplet_count {
    type = number
    default = 2
}

variable "name" {
    type = string
    default = "jgstudios"
}

variable "image" {
    type = string
    default = "ubuntu-20-04-x64"
}

variable "droplet_size" {
    type = string
    default = "s-1vcpu-1gb"
}

//variable "ssh_key" {
//    type = string
//}

variable "subdomain" {
    type = string
    default = "jgs"
}

variable "domain_name" {
    type = string
    default = "johnthevos.com"
}

variable "access_id" {
    type = string
    default = "VETWMMG2IXBCMIC4OCRD"
}

variable "secret_key" {
    type = string
    default = "BZtZivkr4wFCQSLHgEnfgE5jc9jQFtbFrIopa/Wal8c"
}
