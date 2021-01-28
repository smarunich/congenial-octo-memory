output "internal_id" {
    value = aws_security_group.octomaster-internal.id
}

output "ingress_id" {
    value = aws_security_group.octomaster-allow-ingress.id
}
