variable "random_pet_length" {
    default = 1
    type = number
}

variable "random_pet_separator" {
    default = "-"
    type = string
}

variable "centos_search" {
    default = "CentOS Linux 7*"
    type = string
}

variable "debian_search" {
    default = "debian-stretch*"
    type = string
}