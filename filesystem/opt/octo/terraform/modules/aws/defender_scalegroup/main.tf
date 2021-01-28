resource "aws_placement_group" "defender_asg" {
  count    = var.enable_placement_groups == true ? 1:0 
  name     = "${var.name_prefix}-defender-asg-placement"
  strategy = "spread"
  tags = merge({ Name = "${var.name_prefix}-${var.instance_name}-placement" },
        var.aws_tags)
}

data "template_file" "host_userdata" {
  template = file("${path.module}/userdata/defender-asg.userdata")
  vars = {
    instance_name = var.instance_name
    public_key = var.public_key
    octo_cluster_uuid = var.octo_cluster_uuid
  }
}

resource "aws_launch_template" "defender_scalegroup" {
  name = "${var.name_prefix}-${var.instance_name}-launch-template"
  image_id = var.ami_id
  instance_type   = var.instance_flavour
  key_name        = var.key_name
  iam_instance_profile {
    name = var.iam_instance_profile
  } 
  user_data  = base64encode(data.template_file.host_userdata.rendered)

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups = var.security_group_ids
  }
  
  block_device_mappings  {
      device_name = var.disks[0].device_name
      ebs {
        volume_size           = var.disks[0].size
        delete_on_termination = true
        volume_type           = "gp2"
      }
  }
  block_device_mappings  {
      device_name = var.disks[1].device_name
      ebs {
        volume_size           = var.disks[1].size
        delete_on_termination = true
        volume_type           = "gp2"
      }
  }


  tags = merge({ Name = "${var.name_prefix}-${var.instance_name}", octo_instance = var.instance_name, octo_role = var.groups }, var.aws_tags)
}
locals {
  asg_tag_map = merge({ Name = "${var.name_prefix}-${var.instance_name}-scalegroup", octo_instance = var.instance_name, octo_role = var.groups }, var.aws_tags)
  keys   = keys(local.asg_tag_map)
  values = values(local.asg_tag_map)
}

data "null_data_source" "asg_tag_list" {
  count = length(local.keys)
  inputs = {
    key                 = local.keys[count.index]
    value               = local.values[count.index]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "defender_scalegroup" {
  name = "${var.name_prefix}-${var.instance_name}-scalegroup"
  placement_group = var.enable_placement_groups == true ? aws_placement_group.defender_asg.0.id:""
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = var.health_check_type
  min_size                  = var.min_count
  min_elb_capacity          = var.min_count
  max_size                  = var.max_count
  desired_capacity          = var.instance_count
  wait_for_capacity_timeout = 0
  target_group_arns         = [ var.defender_tg_http_arn,   
                              var.defender_tg_https_arn ]
  launch_template {
    id      = aws_launch_template.defender_scalegroup.id
    version = aws_launch_template.defender_scalegroup.latest_version
  }
  tags = data.null_data_source.asg_tag_list.*.outputs
}

resource aws_autoscaling_policy scaling_policy {
  name                    = "${var.name_prefix}-${var.instance_name}-cpu-based-policy"
  adjustment_type         = "ChangeInCapacity"
  policy_type             = "TargetTrackingScaling"
  autoscaling_group_name  = aws_autoscaling_group.defender_scalegroup.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }

}