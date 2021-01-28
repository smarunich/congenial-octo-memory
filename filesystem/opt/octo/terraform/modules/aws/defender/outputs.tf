output "hostnames" {
  value = [ for i in aws_instance.instance : lookup(i.tags, "Name") ]
}

output "private_ips" {
    value = aws_instance.instance.*.private_ip
}

output "public_ips" {
    value = aws_instance.instance.*.public_ip
}
output "defender_ids" {
    value = aws_instance.instance.*.id
}