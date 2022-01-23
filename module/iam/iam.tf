#EC2 IAM Role
resource "aws_iam_role" "default_ec2_role" {
  name               = "default-ssm-ec2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF


  tags = merge(var.default_iam_tags)
}

#EC2 Instance Profile
resource "aws_iam_instance_profile" "default_ec2_profile" {
  name = "default-ssm-ec2"
  role = aws_iam_role.default_ec2_role.id
}

#Attach Policies to EC2 Instance Role
resource "aws_iam_policy_attachment" "default_ec2_attach1" {
  name       = "default-ec2-attachment1"
  roles      = [aws_iam_role.default_ec2_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "default_ec2_attach2" {
  name       = "default-ec2-attachment2"
  roles      = [aws_iam_role.default_ec2_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
