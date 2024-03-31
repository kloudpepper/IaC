##################
### ALB Module ###
##################

locals {
  targets = ["WEB", "APP"]
}

# Create Target Groups
resource "aws_lb_target_group" "target_group" {
  count = length(local.targets)
  health_check {
    interval            = 60
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
    unhealthy_threshold = 10
    healthy_threshold   = 2
    matcher             = "200"
  }
  stickiness {
    enabled         = local.targets[count.index] == "WEB" ? true : false
    type            = "lb_cookie"
    cookie_duration = 86400
  }
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  name                 = "${var.environment_Name}-${local.targets[count.index]}-TG"
  deregistration_delay = 10
}

# Create ALB
resource "aws_lb" "alb" {
  name               = "${var.environment_Name}-ALB"
  internal           = true
  load_balancer_type = "application"
  subnets            = length(var.private_subnet_ids) == 4 ? slice(var.private_subnet_ids, 0, 2) : length(var.private_subnet_ids) == 6 ? slice(var.private_subnet_ids, 0, 2, 4) : var.private_subnet_ids
  security_groups    = [var.alb_sg_id]
  ip_address_type    = "ipv4"
  access_logs {
    enabled = true
    bucket  = "${var.environment_Name}-access-logs"
    prefix  = ""
  }
  idle_timeout               = "60"
  enable_deletion_protection = false
  enable_http2               = true
}

# Create Listeners
resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  #ssl_policy        = ""
  #certificate_arn   = ""
  default_action {
    fixed_response {
      content_type = "text/plain"
      message_body = "Wrong path..."
      status_code  = "404"
    }
    type = "fixed-response"
  }
}

# Create Listener Rules
resource "aws_lb_listener_rule" "rule_1" {
  count        = length(local.targets)
  priority     = 1
  listener_arn = aws_lb_listener.listener_80.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[0].arn
  }
  condition {
    path_pattern {
      values = ["/web*"]
    }
  }
}

resource "aws_lb_listener_rule" "rule_2" {
  count        = length(local.targets)
  priority     = 2
  listener_arn = aws_lb_listener.listener_80.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[1].arn
  }
  condition {
    path_pattern {
      values = ["/app*"]
    }
  }
}

# Create a S3 bucket for ALB access logs
resource "aws_s3_bucket" "access_logs_bucket" {
  bucket        = "${var.environment_Name}-access-logs"
  force_destroy = true
  tags = {
    Name = "${var.environment_Name}-access-logs"
  }
}

resource "aws_s3_bucket_policy" "access_logs_bucket_policy" {
  bucket = aws_s3_bucket.access_logs_bucket.bucket
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.elb-account-id[var.aws_Region]}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.access_logs_bucket.bucket}/*"
    }
  ]
}
POLICY
}