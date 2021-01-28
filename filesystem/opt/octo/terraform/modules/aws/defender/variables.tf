variable "instance_name" {
    type = string
}

variable "ami_id" {
    type = string
}

variable "key_name" {
    type = string
}

variable "subnet_ids" {
    type = list
}

variable "security_group_ids" {
    type = list
}

variable "disks" {
    type = list
}

variable "instance_count" {
    type = string
}

variable "instance_flavour" {
    type = string
}

variable "public_key" {
    type = string
}

variable "name_prefix" {
    type = string
}

variable "octo_cluster_uuid" {
    type = string
}

variable "iam_instance_profile" {
    type=string
}

variable "groups" {
    type = string
}

variable "associate_public_ip_address" {
    type = bool
}

variable "aws_tags" {
    type = map 
}

variable "enable_placement_groups" {
  type = bool
}