resource "random_pet" "random_pet" {
  length    = var.random_pet_length
  separator = var.random_pet_separator
}

resource "random_uuid" "random_uuid" {}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["aws-marketplace"]
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "image-type"
    values = ["machine"]
  }
  filter {
    name   = "name"
    values = [var.centos_search]
  }
}

data "aws_ami" "debian" {
  most_recent = true
  owners = ["379101102735"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "name"
    values = [var.debian_search]
  }
}