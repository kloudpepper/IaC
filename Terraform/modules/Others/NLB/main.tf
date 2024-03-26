##################
### NLB Module ###
##################

locals {
  ports = ["7800", "7826", "7832"]
}

resource "aws_lb_target_group" "TargetGroups" {
  count                  = length(local.ports)
  name                   = "${var.environmentName}-IIB-${local.ports[count.index]}-TG"
  port                   = local.ports[count.index]
  protocol               = "TCP"
  target_type            = "ip"
  vpc_id                 = var.vpc_id
  preserve_client_ip     = false
  connection_termination = true
  deregistration_delay   = 10
  health_check {
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }
}

resource "aws_lb" "NetworkLoadBalancer" {
  name                             = "${var.environmentName}-NLB-IIB-onpremise"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = [var.PrivateSubnet1_id, var.PrivateSubnet2_id]
  ip_address_type                  = "ipv4"
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "TCPListeners" {
  depends_on        = [aws_lb_target_group.TargetGroups, aws_lb.NetworkLoadBalancer]
  count             = length(local.ports)
  load_balancer_arn = aws_lb.NetworkLoadBalancer.arn
  port              = local.ports[count.index]
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TargetGroups[count.index].arn
  }
}

resource "aws_lb_target_group_attachment" "TargetGroupsAttachment" {
  depends_on        = [aws_lb_target_group.TargetGroups]
  count             = length(local.ports)
  target_group_arn  = aws_lb_target_group.TargetGroups[count.index].arn
  target_id         = var.ip_nat_IIB_onpremise
  availability_zone = "all"
  port              = local.ports[count.index]
}