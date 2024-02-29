##################
### ALB Module ###
##################

locals {
  targets = ["WEB", "DEV", "DEVL3", "TCUA", "APP"]
}

resource "aws_lb_target_group" "TargetGroups" {
    count = length(local.targets)
    health_check {
        interval = 60
        path = "/"
        port = "traffic-port"
        protocol = "HTTPS"
        timeout = 30
        unhealthy_threshold = 10
        healthy_threshold = 2
        matcher = "200"
    }
    stickiness {
        enabled = local.targets[count.index] == "WEB" ? true : false
        type = "lb_cookie"
        cookie_duration = 86400
    }
    port = 8443
    protocol = "HTTPS"
    target_type = "ip"
    vpc_id = var.vpc_id
    name = "${var.environmentName}-${local.targets[count.index]}-TG"
    deregistration_delay = 10
}

resource "aws_lb" "AplicationLoadBalancer" {
    name = "${var.environmentName}-ALB"
    internal = true
    load_balancer_type = "application"
    subnets = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    security_groups = [var.ALBSecurityGroup_id]
    ip_address_type = "ipv4"
    /* access_logs {
        enabled = true
        bucket = "access-logs-alb-all-account"
        prefix = ""
    } */
    idle_timeout = "180"
    enable_deletion_protection = false
    enable_http2 = true
}

resource "aws_lb_listener" "HTTPSListener" {
    load_balancer_arn = aws_lb.AplicationLoadBalancer.arn
    port = 443
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
    certificate_arn = var.certificate_ARN
    default_action {
        fixed_response {
            content_type = "text/plain"
            message_body = "Inserte la ruta correcta..."
            status_code = "404"
        }
        type = "fixed-response"
    }
}

resource "aws_lb_listener_rule" "ListenerRule1" {
    count = length(local.targets)
    priority = 1
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[2].arn
    }
    condition {
        path_pattern {
            values = ["/DCDE-irf-Services*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule2" {
    count = length(local.targets)
    priority = 2
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[1].arn
    }
    condition {
        path_pattern {
            values = ["/irf-provider-container*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule3" {
    count = length(local.targets)
    priority = 3
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[1].arn
    }
    condition {
        path_pattern {
            values = ["/irf-test-web*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule4" {
    count = length(local.targets)
    priority = 4
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[1].arn
    }
    condition {
        path_pattern {
            values = ["/PSD2payments*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule5" {
    count = length(local.targets)
    priority = 5
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[1].arn
    }
    condition {
        path_pattern {
            values = ["/irf-web-client*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule6" {
    count = length(local.targets)
    priority = 6
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[3].arn
    }
    condition {
        path_pattern {
            values = ["/tc-useradmin-api*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule7" {
    count = length(local.targets)
    priority = 7
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[3].arn
    }
    condition {
        path_pattern {
            values = ["/UserAdministration*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule8" {
    count = length(local.targets)
    priority = 8
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[0].arn
    }
    condition {
        path_pattern {
            values = ["/tc-channels-api*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule9" {
    count = length(local.targets)
    priority = 9
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[0].arn
    }
    condition {
        path_pattern {
            values = ["/BrowserWeb*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule10" {
    count = length(local.targets)
    priority = 10
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[4].arn
    }
    condition {
        path_pattern {
            values = ["/axis2*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule11" {
    count = length(local.targets)
    priority = 11
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[4].arn
    }
    condition {
        path_pattern {
            values = ["/TAFJEE*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule12" {
    count = length(local.targets)
    priority = 12
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[4].arn
    }
    condition {
        path_pattern {
            values = ["/TAFJSanitycheck*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule13" {
    count = length(local.targets)
    priority = 13
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[4].arn
    }
    condition {
        path_pattern {
            values = ["/TAFJCobMonitor*"]
            }
    }
}

resource "aws_lb_listener_rule" "ListenerRule14" {
    count = length(local.targets)
    priority = 14
    listener_arn = aws_lb_listener.HTTPSListener.arn
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TargetGroups[4].arn
    }
    condition {
        path_pattern {
            values = ["/TAFJRestServices/*"]
            }
    }
}