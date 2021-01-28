resource aws_eip "nlb_eip" {
  count = length(var.subnet_ids)
  vpc = true
  tags = merge({ Name = format("${var.name_prefix}-eip%02d", count.index + 1) },
          var.aws_tags)
}

resource "aws_lb" "defender_nlb" {
  name               = "${var.name_prefix}-defender-tg-http" 
  load_balancer_type = "network"

  dynamic "subnet_mapping" {
    for_each = zipmap(var.subnet_ids, aws_eip.nlb_eip.*.id)
    content {
      subnet_id     = subnet_mapping.key
      allocation_id = subnet_mapping.value
    }
  }

  tags = merge({ Name = "${var.name_prefix}-defender-nlb" },
          var.aws_tags)
}

resource "aws_lb_target_group" "defender_tg_http" {
  name     = "${var.name_prefix}-defender-tg-http" 
  port     = 8080
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    #timeout             = 3
    interval            = 10
    path                = "/.stealth-check"
  }
  tags = merge({ Name = "${var.name_prefix}-defender-tg-http" },
          var.aws_tags)
}

resource "aws_lb_target_group" "defender_tg_https" {
  name     = "${var.name_prefix}-defender-tg-https"  
  port     = 8443
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    port                = 8443
    protocol            = "HTTPS"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    #timeout             = 3
    interval            = 10
    path                = "/.stealth-check"
  }
  tags = merge({ Name = "${var.name_prefix}-defender-tg-https" },
          var.aws_tags)
}

resource "aws_lb_listener" "defender_listen_http" {
  load_balancer_arn = aws_lb.defender_nlb.arn
  port = "8080"
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.defender_tg_http.arn
  }
}

resource "aws_lb_listener" "defender_listen_https" {
  load_balancer_arn = aws_lb.defender_nlb.arn
  port = "8443"
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.defender_tg_https.arn
  }
}

resource "aws_lb_target_group_attachment" "attachment-http" {
  count = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.defender_tg_http.arn
  target_id        = var.instance_ids[count.index] 
}

resource "aws_lb_target_group_attachment" "attachment-https" {
  count = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.defender_tg_https.arn
  target_id        = var.instance_ids[count.index] 
}
