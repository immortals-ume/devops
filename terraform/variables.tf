variable "aws_region" { default = "ap-south-1" }
variable "vpc_cidr" { default = "10.0.0.0/16" }

variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "key_name" { description = "Existing AWS key pair" }
variable "allowed_ip" { description = "SSH access IP", default = "YOUR_IP/32" }

variable "domain_name" { description = "Route53 domain" }
variable "subdomain" { description = "App subdomain", default = "app" }

variable "instance_type" { default = "t3.micro" }
variable "desired_capacity" { default = 2 }
variable "max_size" { default = 4 }
variable "min_size" { default = 1 }
