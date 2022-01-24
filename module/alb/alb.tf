#CREATES SECURITY GROUP FOR WEBSERVER LOAD BALANCER
resource "aws_security_group" "sg_frontend_lb" {
  name        = "sg_frontend_lb"
  description = "Security Group used WebServer Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP inbound rule for all"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Default outbound rule"
  }

  tags = merge(var.default_lb_sg_tags)

}


#CREATES ALB FOR WEB SERVERS
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "webalb-french"

  load_balancer_type = "application"

  internal        = false
  vpc_id          = var.vpc_id
  subnets         = ["${var.external_subnet_ids[0]}", "${var.external_subnet_ids[1]}"]
  security_groups = [aws_security_group.sg_frontend_lb.id]
  http_tcp_listeners = [
    {
      port               = 80,
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  access_logs = {
    bucket = "french-lab-logging-2022"
  }

  tags = merge(var.default_alb_tags)

  target_groups = [
    {
      name_prefix      = "appsvr",
      backend_protocol = "HTTP",
      backend_port     = 80
      target_type      = "instance"
    }
  ]
} 