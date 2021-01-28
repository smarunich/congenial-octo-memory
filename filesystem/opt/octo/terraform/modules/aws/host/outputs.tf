output "private_ips" {
  value = [ for i in aws_instance.instance : i.private_ip ]
}
output "public_ips" {
  value = [ for i in aws_instance.instance : i.public_ip ]
}

output "hostnames" {
  value = [ for i in aws_instance.instance : lookup(i.tags, "Name") ]
}
