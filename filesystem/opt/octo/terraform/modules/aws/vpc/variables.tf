variable "vpc_cidr" {
    type    = string
}

variable "min_az_count" {
    type = number
}

variable "max_az_count" {
    type = number
}
variable "name_prefix" {
    type = string
}
variable "aws_tags" {
    type = map 
}