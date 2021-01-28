resource "aws_placement_group" "defender" {
  count    = var.enable_placement_groups == true ? 1:0 
  name     = "${var.name_prefix}-defender-placement"
  strategy = "spread"
  tags = merge({ Name = "${var.name_prefix}-${var.instance_name}-placement" },
        var.aws_tags)
}

data "template_file" "host_userdata" {
  count    = var.instance_count
  template = file("${path.module}/userdata/defender.userdata")

  vars = {
    instance_name = var.instance_name
    public_key = var.public_key
    octo_cluster_uuid = var.octo_cluster_uuid
    }
}

resource "aws_instance" "instance" {
  count = var.instance_count
  ami = var.ami_id
  placement_group = var.enable_placement_groups == true ? aws_placement_group.defender.0.id:""
  instance_type = var.instance_flavour
  key_name = var.key_name
  iam_instance_profile = var.iam_instance_profile
  subnet_id = element(var.subnet_ids, count.index)
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids = var.security_group_ids
  user_data = data.template_file.host_userdata[count.index].rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = var.disks[0].size
  }
  ebs_block_device {
    volume_type = "gp2"
    volume_size = var.disks[1].size
    device_name = var.disks[1].device_name
  }

  tags = merge({ Name = format("${var.name_prefix}-${var.instance_name}%02d", count.index + 1), octo_instance = var.instance_name, octo_role = var.groups },
         var.aws_tags)
  volume_tags = merge({ Name = format("${var.name_prefix}-${var.instance_name}%02d", count.index + 1) },
         var.aws_tags)
}