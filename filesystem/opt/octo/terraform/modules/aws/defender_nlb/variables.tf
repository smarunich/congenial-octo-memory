variable "vpc_id" {
    type = string
}

variable "subnet_ids" {
    type = list
}

variable "instance_ids" {
    type = list
}

variable "name_prefix" {
    type = string
}

variable "aws_tags" {
    type = map 
}

