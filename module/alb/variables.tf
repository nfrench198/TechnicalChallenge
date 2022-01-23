variable "default_alb_tags" {
  default = {
    "Name" : "http-alb"
    "department" : "cloudenablement",
    "team" : "cloudserver",
    "contact" : "cloudserver@frenchscompany.com"
    "env" : "dev"
  }
}

variable "default_lb_sg_tags" {
  default = {
    "Name" : "sg_frontend_lb"
    "department" : "cloudenablement",
    "team" : "cloudnetworksecurity",
    "contact" : "cloudnetworksecurity@frenchscompany.com"
    "env" : "dev"
  }
}