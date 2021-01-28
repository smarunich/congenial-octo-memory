output "random_name" {
  value = random_pet.random_pet.id
}

output "random_uuid" {
  value = random_uuid.random_uuid.id
}


output "latest_centos_ami" {
  value = data.aws_ami.centos.id
}

output "latest_debian_ami" {
  value = data.aws_ami.debian.id
}
