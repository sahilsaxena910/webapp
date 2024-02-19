resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_rt_name
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "lb" {
  vpc_id = aws_vpc.main.id
  name = var.alb_sg_name
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.alb_sg_name
  }
}

resource "aws_security_group" "private_instance" {
  vpc_id = aws_vpc.main.id
  name = var.ec2_sg_name
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }
  
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  ingress {
    from_port       = 1
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.ec2_sg_name
  }
}

resource "aws_launch_template" "web_launch_template" {
  name                   = "web-launch-template"
  image_id               = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.private_instance.id]
  user_data              = var.isDocker ? base64encode(file("${path.module}/user_data_docker.sh")) : base64encode(file("${path.module}/user_data_ansible.sh")) ## base64 encoding of user data script is required by aws
  key_name               = "ContainerKey"
  block_device_mappings {
    device_name = "/dev/xvda" # Root volume
    ebs {
      volume_size = var.ebs_root_volume_size
      encrypted   = true
    }
  }

  block_device_mappings {
    device_name = "/dev/xvdf" # Secondary volume for logs
    ebs {
      volume_size = var.ebs_secondary_volume_size
      encrypted   = true
    }
  }

}

resource "aws_autoscaling_group" "web_autoscaling_group" {
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_capacity
  min_size            = var.asg_min_capacity
  vpc_zone_identifier = aws_subnet.private[*].id
  name = var.asg_name
  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = aws_launch_template.web_launch_template.latest_version
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "web-instance"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "nat_sg" {
  vpc_id = aws_vpc.main.id
  name   = "nat-security-group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat-security-group"
  }
}
resource "aws_eip" "nat_eip" {
  domain = "vpc" 
  depends_on = [ aws_internet_gateway.igw ]
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id 

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false 
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]

  enable_deletion_protection = false 

  subnets = aws_subnet.public[*].id

  enable_http2               = true
  enable_cross_zone_load_balancing = true
  
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }
}

resource "aws_lb_listener" "web_alb_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.web_target_group.arn
    type             = "forward"
  }

}
resource "aws_lb_listener" "web_alb_listener_https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    target_group_arn = aws_lb_target_group.web_target_group.arn
    type             = "forward"
  }

  ssl_policy       = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.self_signed_acm_cert.arn
}
resource "aws_autoscaling_attachment" "web_autoscaling_attachment" {
  lb_target_group_arn  = aws_lb_target_group.web_target_group.arn
  autoscaling_group_name = aws_autoscaling_group.web_autoscaling_group.name
}

resource "tls_private_key" "self_signed_cert" {
  algorithm = "RSA"
}

# resource "tls_cert_request" "self_signed_cert_csr" {
#   private_key_pem = tls_private_key.self_signed_cert.private_key_pem
#   dns_names = ["test.example.com"]
# }

resource "tls_self_signed_cert" "self_signed_cert" {
  private_key_pem = tls_private_key.self_signed_cert.private_key_pem
  subject {
    common_name  = "test.example.com"
    organization = "Example Organization"
  }

  validity_period_hours = 8760 # 1 year
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

resource "aws_route53_zone" "private_zone" {
  name                      = "example.com"
  vpc {
    vpc_id = aws_vpc.main.id
  }
  tags = {
    Name = "private-hosted-zone"
  }
}

resource "aws_route53_record" "alb_dns_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "test.example.com"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.web_alb.dns_name]
}

resource "aws_acm_certificate" "self_signed_acm_cert" {
  private_key        = tls_self_signed_cert.self_signed_cert.private_key_pem
  certificate_body   = tls_self_signed_cert.self_signed_cert.cert_pem

  tags = {
    Name = "self-signed-certificate"
  }
}

resource "aws_autoscaling_policy" "remove_capacity_policy" {
  name                   = "RemoveCapacityPolicy"
  scaling_adjustment    = -1
  cooldown              = 300
  adjustment_type       = "ChangeInCapacity"
  estimated_instance_warmup = 300
  autoscaling_group_name = aws_autoscaling_group.web_autoscaling_group.name
}

resource "aws_autoscaling_policy" "add_capacity_policy" {
  name                   = "AddCapacityPolicy"
  scaling_adjustment    = 1
  cooldown              = 300
  adjustment_type       = "ChangeInCapacity"
  estimated_instance_warmup = 300
  autoscaling_group_name = aws_autoscaling_group.web_autoscaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_over" {
  alarm_name          = "CPUUtilizationAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when CPU exceeds 80%"
  alarm_actions       = [aws_autoscaling_policy.add_capacity_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_under" {
  alarm_name          = "CPUUtilizationAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "Alarm when CPU utilization is less than 50%"
  alarm_actions       = [aws_autoscaling_policy.remove_capacity_policy.arn]
}



