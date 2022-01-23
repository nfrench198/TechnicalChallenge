variable "default_iam_tags" {
  default = {
    "name" = "default-ssm-ec2"
    "department" : "cloudenablement",
    "team" : "cloudsecurity",
    "contact" : "cloudsecurity@frenchscompany.com"
    "environment" : "dev"
  }
}