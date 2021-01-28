resource "aws_iam_role" "iam_role" {
  name = "${var.name_prefix}_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "iam_role_policy" {
  name   = "${var.name_prefix}_iam_policy"
  role   = aws_iam_role.iam_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:DescribeTags",
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.name_prefix}_iam_instance_profile"
  role = aws_iam_role.iam_role.name
}