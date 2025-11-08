# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "prod-vpc" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "prod-igw" }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.key
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}${index(var.public_subnets, each.key)+1}"
  tags = { Name = "public-subnet-${each.key}" }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.key
  availability_zone = "${var.aws_region}${index(var.private_subnets, each.key)+1}"
  tags = { Name = "private-subnet-${each.key}" }
}

# NAT Gateways
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  tags          = { Name = "nat-${each.key}" }
  depends_on    = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0"; gateway_id = aws_internet_gateway.igw.id }
  tags   = { Name = "public-rt" }
}

# Private Route Tables
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[element(keys(aws_subnet.public), index(keys(aws_subnet.private), each.key))].id
  }
  tags = { Name = "private-rt-${each.key}" }
}

# Route Table Associations
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id
  ingress { from_port=80; to_port=80; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
  ingress { from_port=443; to_port=443; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
  egress  { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow traffic from ALB"
  ingress     { from_port=80; to_port=80; protocol="tcp"; security_groups=[aws_security_group.alb_sg.id] }
  egress      { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version="2012-10-17"
    Statement=[{
      Action="sts:AssumeRole"
      Effect="Allow"
      Principal={Service="ec2.amazonaws.com"}
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Launch Template
resource "aws_launch_template" "private_template" {
  name_prefix   = "private-ec2-"
  image_id      = "ami-0de53d8956e8dcf80"
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = values(aws_subnet.private)[*].id
  launch_template { id=aws_launch_template.private_template.id; version="$Latest" }
  target_group_arns = [aws_lb_target_group.app_tg.arn]
  health_check_type = "ELB"
  force_delete      = true
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = values(aws_subnet.public)[*].id
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path = "/"; protocol="HTTP"; healthy_threshold=2; unhealthy_threshold=2; timeout=3; interval=30
  }
}

# ALB Listeners
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action { type="forward"; target_group_arn=aws_lb_target_group.app_tg.arn }
}

# ACM Certificate
resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "${var.subdomain}.${var.domain_name}"
  validation_method = "DNS"
}

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = aws_acm_certificate.ssl_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.ssl_cert.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.ssl_cert.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.ssl_cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

# HTTPS Listener
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn
  default_action { type="forward"; target_group_arn=aws_lb_target_group.app_tg.arn }
}

# Route53 Record for App
resource "aws_route53_record" "app_dns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.subdomain
  type    = "A"
  alias { name=aws_lb.app_lb.dns_name; zone_id=aws_lb.app_lb.zone_id; evaluate_target_health=true }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = "ami-0de53d8956e8dcf80"
  instance_type          = var.instance_type
  subnet_id              = values(aws_subnet.public)[0].id
  vpc_security_group_ids = [aws_security_group.alb_sg.id]
  key_name               = var.key_name
  associate_public_ip_address = true
  tags = { Name = "bastion-host" }
}

# S3 Bucket for ALB Logs
resource "aws_s3_bucket" "alb_logs" {
  bucket = "alb-logs-${random_id.bucket_id.hex}"
  acl    = "private"
  versioning { enabled = true }
}

resource "random_id" "bucket_id" {
  byte_length = 4
}
