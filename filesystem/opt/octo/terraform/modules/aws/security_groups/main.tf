resource "aws_security_group" "octomaster-internal" {
  name        = "${var.name_prefix}-internal"
  description = "Internal cluster communications"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ALL within this group"
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }

  tags = merge({ Name = "${var.name_prefix}-internal" },
          var.aws_tags)
}

resource "aws_security_group" "octomaster-allow-ingress" {
  name        = "${var.name_prefix}-ingress"
  description = "Allow ingress communications from external"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Defender HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Defender HTTPS"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${var.name_prefix}-ingress" },
          var.aws_tags)
}
