# CREATES KMS KEY FOR EBS ENCRYPTION

# CREATES USERDATA FOR WEBSERVER LAUNCH TEMPLATE
data "template_file" "WebServerUD" {
  template = <<EOF
#!/bin/bash
yum update
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
hostnamectl set-hostname bastionhost
  EOF
}

# LOOKUP FOR RHEL AMI
data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-8.4.0_HVM-*x86*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#CREATES SECURITY GROUP FOR EXTERNAL FACING BASTION HOST
resource "aws_security_group" "sg_bastion_host" {
  name        = "sg_bastion_host"
  description = "Security Group used for Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["96.35.2.243/32"]
    description = "SSH inbound from common remote office"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Default outbound rule"
  }

  tags = merge(var.default_bastion_sg_tags)

}

# CREATES KEYPAIR TO BE USED ON BASTION HOST
resource "aws_key_pair" "bastion-kp" {
  key_name   = "bastion-kp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAzplpjidMQGdVpoR8gR07HmELd7okl0mr+OvYPP7Xd2Yd6CgEXhdtM/TnP9jR7XGii48NbNPzOjVpIs+g05ADWoZtotTz99H9uxQJDgz9IYYbIbyR0KBL698ewTXhXq9S+oPnqLj8X2+DKdVZBmO5j0mrlC9j8NwJVx8MhlxOPhcJ0mrY08Ah9X772Gt1GH9WFC9nyC9+aCP9A6P1zJDAmeb+Iw0GiSriQ3fVIKbVy7nuZEEPSSaFrmp3xLGjVTHVwwr663I+Gm6EnpjX/HyD7imkcdsUwEJrnY4tX9zarvG8K1JohSC7HbeZWgjgryEu/Z/K/Hr4A/zvRrQ6rGoIxw== rsa-key-20220112"
}

# CREATES EC2 BASTION INSTANCE
resource "aws_instance" "bastion_host" {
  ami                  = data.aws_ami.rhel.id
  instance_type        = "t3.micro"
  subnet_id            = var.external_subnet_id
  key_name             = "bastion-kp"
  iam_instance_profile = var.ec2_role
  ebs_optimized        = true
  monitoring           = true
  user_data            = base64encode(data.template_file.WebServerUD.rendered)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  vpc_security_group_ids = [
    aws_security_group.sg_bastion_host.id
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"
    encrypted             = true
  }

  tags = merge(var.default_ec2_tags)
}