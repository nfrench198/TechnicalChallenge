variable "default_ec2_tags" {
  default = {
    "Name" : "BastionServer"
    "department" : "cloudenablement",
    "team" : "cloudserver",
    "contact" : "cloudserver@frenchscompany.com"
    "env" : "dev"
  }
}

variable "default_bastion_sg_tags" {
  default = {
    "Name" : "sg_bastion_server"
    "department" : "cloudenablement",
    "team" : "cloudnetworksecurity",
    "contact" : "cloudnetworksecurity@frenchscompany.com"
    "env" : "dev"
  }
}