output "key_name" {
  value = aws_key_pair.generated.key_name
}

output "public_key" {
  value = tls_private_key.generated.public_key_openssh
}