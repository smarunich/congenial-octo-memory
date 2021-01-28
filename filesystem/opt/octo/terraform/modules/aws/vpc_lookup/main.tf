data "aws_vpc" "octomaster_vpc" {
  filter {
    name = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet_ids" "octomaster_subnet" {
  vpc_id = data.aws_vpc.octomaster_vpc.id
  filter {
    name = "tag:Name"
    values = var.subnet_names
  }
}

locals {
  subnet_ids_string = join(",", data.aws_subnet_ids.octomaster_subnet.ids)
  subnet_ids_list = split(",", local.subnet_ids_string)
}