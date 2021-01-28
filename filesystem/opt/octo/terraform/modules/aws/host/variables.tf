variable "instance_name" {
    type = string
}

variable "ami_id" {
    type = string
}

variable "key_name" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "security_group_ids" {
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

variable "disks" {
    type = list
}

variable "name_prefix" {
    type = string
}

variable "aws_tags" {
    type = map 
}

variable "groups" {
    type = string
}

variable "octo_cluster_uuid" {
    type = string
}

variable "iam_instance_profile" {
    type=string
}

variable "associate_public_ip_address" {
    type = bool
}

variable "delete_on_termination" {
    type = bool
}

variable "enable_placement_groups" {
  type = bool
}