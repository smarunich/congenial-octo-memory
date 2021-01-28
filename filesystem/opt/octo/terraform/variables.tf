
variable "aws_region" {
  default = "us-west-2"
}

variable "aws_profile" {
}

variable "aws_key_pair_reuse" {
  type = bool
  default = false
}
variable "aws_key_pair_name" {
  type = string
  default = ""
}
variable "aws_key_pair_public_key" {
  type = string
  default = ""
}

variable "iam_reuse" {
  type = bool
  default = false
}
variable "iam_instance_profile_name" {
  type = string
  default = ""
}
variable "tier" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "vpc_reuse" {
  type = bool
  default = false
}

variable "cidr" {
  default = "10.255.0.0/16"
}

variable "vpc_name" {
  type = string
  default = ""
}

variable "subnet_names" {
  type = list
  default = []
}

variable "security_group_reuse" {
  type = bool
  default = false
}

variable "security_group_id" {
  type = string
  default = ""
}

variable "ami_id" {
  type = string
  default = ""
}

variable "defender_asg_ami_id" {
  default = ""
  type = string
}

variable "enable_placement_groups" {
  default = true
  type = bool
}

variable "associate_public_ip_address" {
  type = bool
  default = true
}

variable "delete_on_termination" {
  type = bool
  default = true
}

variable "aws_tags" {
  type = map 
  default = { "Application"="octo", 
    "Environment"="Production" }
}

variable "defender_mode_scalegroup" {
  type = bool
  default = true
}

variable "defender_scalegroup_health_check_type" {
  type = string
  default = "EC2"
}

variable "inventory_ip_address_type" {
    type = string
    default = "private-ip-address"
}

locals {
  yaml = yamldecode(file("../installer/group_vars/all.yml"))
  tier_data = lookup(local.yaml.tiers, var.tier)
  octomaster = lookup(local.tier_data, "octomaster")
  defenders = lookup(local.tier_data, "defender")
  defender_infra = lookup(local.yaml.infra.aws, "defender")
}
