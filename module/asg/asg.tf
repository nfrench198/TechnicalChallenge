# LOOKUP FOR LATEST AWS LINUX AMI
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

# CREATES KEYPAIR TO BE USED ON WEB SERVERS
resource "aws_key_pair" "webserver-kp" {
  key_name   = "webserver-kp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAtx2QnwQtWW7HWj8UmyPa5wgbQLoCYL0WXc2NgwyDCSF6nasM7kFYgIWRXkvnSO3MBsueIS6n2k0GKC2+Z9wmP2AaHOIE751+zmn5E9vBuiesk1jnMlprceruNCl+MYC2uW/OukXagTtXP+5kIefr5jWkuJIGW1RUND2zz56EHuA5G81hEgcm5yZ4GcKXU4r9BWRIkLwfm2mGLRPET1jXqG32W1NPa2S9r63G/cGX6AEpq63fTUSzOvQzqLUiLyLqWbOqNz3FmAJUCebPYZX1pP71xFzXaj2C7+cXjfRYJDZe1Sf1ojU1oDOJ657te9gYXayTmbyM8p7I6OE8IlI6/w== rsa-key-20220114"
}


#CREATES SECURITY GROUP FOR WEB SERVERS
resource "aws_security_group" "sg_webserver" {
  name        = "sg_webserver"
  description = "Security Group used WebServers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP inbound for local traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Default outbound rule"
  }

  tags = merge(var.default_webserver_sg_tags)

}

# CREATES USERDATA FOR WEBSERVER LAUNCH TEMPLATE
data "template_file" "WebServerUD" {
  template = <<EOF
#!/bin/bash
yum update
yum install -y httpd
systemctl enable httpd.service
systemctl start httpd.service
echo Apache has been installed on RHEL 8.4 > /var/www/html/index.html
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
hostnamectl set-hostname webhost
  EOF
}

# CREATES WEBSERVER LAUNCH TEMPLATE
resource "aws_launch_template" "webserver_template" {
  name          = "WebServer"
  image_id      = data.aws_ami.rhel.id
  instance_type = "t3.micro"
  user_data     = base64encode(data.template_file.WebServerUD.rendered)
  key_name      = "webserver-kp"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    security_groups       = [aws_security_group.sg_webserver.id]
    delete_on_termination = true
    subnet_id             = var.internal_subnet_id
    description           = "Primary"
  }

  dynamic "iam_instance_profile" {
    for_each = var.ec2_role != null ? [1] : []
    content {
      name = var.ec2_role
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.default_asg_tags)
  }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
      encrypted   = true
      kms_key_id  = var.ec2_kms_arn
    }
  }
}

# CREATES WEBSERVER AUTO SCALING GROUP
resource "aws_autoscaling_group" "WebServer_ASG" {
  availability_zones = ["us-east-1b"]
  desired_capacity   = 2
  max_size           = 6
  min_size           = 2
  launch_template {
    id      = aws_launch_template.webserver_template.id
    version = "1"
  }
}

# CREATES ALB ATTACHMENT FOR THE WEBSERVER AUTO SCALING GROUP
resource "aws_autoscaling_attachment" "asg_attachment_webserver" {
  autoscaling_group_name = aws_autoscaling_group.WebServer_ASG.id
  alb_target_group_arn   = var.webserver_tg_arn
}