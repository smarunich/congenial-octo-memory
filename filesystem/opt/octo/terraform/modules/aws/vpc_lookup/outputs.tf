output "id" {
  value = data.aws_vpc.octomaster_vpc.id
}

output "subnet_ids" {
  value = local.subnet_ids_list
}