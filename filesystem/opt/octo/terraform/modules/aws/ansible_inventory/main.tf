data "template_file" "ansible-inventory" {
  template = file("${path.module}/templates/ansible-inventory.yml")

  vars = {
    aws_region = var.aws_region
    aws_profile = var.aws_profile
    inventory_ip_address_type = var.inventory_ip_address_type
    octo_cluster_uuid = var.octo_cluster_uuid
    }
}

resource "null_resource" "local" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.ansible-inventory.rendered}\" > /etc/ansible/ansible_plugins/'${var.name_prefix}'_'${var.octo_cluster_uuid}'_aws_ec2.yml"
  }
}