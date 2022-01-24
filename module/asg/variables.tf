variable "default_asg_tags" {
  default = {
    "Name" : "WebServer"
    "department" : "cloudenablement",
    "team" : "cloudserver",
    "contact" : "cloudserver@frenchscompany.com"
    "env" : "dev"
  }
}

variable "default_webserver_sg_tags" {
  default = {
    "Name" : "sg_webserver"
    "department" : "cloudenablement",
    "team" : "cloudnetworksecurity",
    "contact" : "cloudnetworksecurity@frenchscompany.com"
    "env" : "dev"
  }
}