output "id" {
  value = aws_vpc.octomaster_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.octomaster.*.id
}