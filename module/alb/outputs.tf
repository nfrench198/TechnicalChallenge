#INPUTS
variable "vpc_id" {}

variable "external_subnet_ids" {}

#OUTPUTS
output "webserver_tg_arn" {
  value = module.alb.target_group_arns
}