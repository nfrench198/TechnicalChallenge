#VERSION
terraform {
  required_version = "1.0.11"
}
# PROVIDERS
provider "aws" {
  region = var.region
}

# MODULES
module "s3" {
  source = "./Module/s3"
}

module "kms" {
  source = "./Module/kms"
}

module "vpc" {
  source = "./Module/vpc"

  s3_logging_arn = module.s3.s3_logging_bucket_arn
}

module "iam" {
  source = "./Module/iam"
}

module "alb" {
  source = "./Module/alb"

  vpc_id              = module.vpc.vpc_id
  external_subnet_ids = module.vpc.public_subnets
}

module "ec2" {
  source = "./Module/EC2"

  vpc_id             = module.vpc.vpc_id
  external_subnet_id = module.vpc.public_subnets[1]
  ec2_role           = module.iam.ec2_iam_name
}

module "asg" {
  source = "./Module/asg"

  webserver_tg_arn   = module.alb.webserver_tg_arn[0]
  vpc_id             = module.vpc.vpc_id
  internal_subnet_id = module.vpc.private_subnets[1]
  ec2_role           = module.iam.ec2_iam_name
  ec2_kms_arn        = module.kms.default_ec2_kms_arn
}
