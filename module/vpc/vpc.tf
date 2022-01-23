# CREATES VPC, SUBNETS, AND GATEWAYS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"
  name    = "french-co-vpc"
  cidr    = "10.1.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.0.0/24", "10.1.1.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(var.default_vpc_tags)
}

#CONFIGUES VPC FLOWLOG
resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = var.s3_logging_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id
}