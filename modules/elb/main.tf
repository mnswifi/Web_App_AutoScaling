################################ ELB #####################################
resource "aws_lb" "elb_web" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = var.security_group_ids
  subnets                    = var.subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = var.tags
}

########################### ELB Listener ################################
resource "aws_lb_listener" "elb_web" {
  for_each          = { for idx, listener in var.listener : idx => listener }
  load_balancer_arn = aws_lb.elb_web.arn
  port              = each.value.lb_port
  protocol          = each.value.lb_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_web_tg[each.key].arn
  }
}

########################### ELB Target Group #############################
resource "aws_lb_target_group" "elb_web_tg" {
  for_each = { for idx, target_grp in var.target_grp : idx => target_grp }
  name     = "${var.tg_name}-${each.key}"
  port     = each.value.instance_port
  protocol = each.value.instance_protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

########################### ELB Attachment ###############################
resource "aws_autoscaling_attachment" "elb_attachment" {
  for_each               = aws_lb_target_group.elb_web_tg
  autoscaling_group_name = var.asg_id
  lb_target_group_arn    = each.value.arn
}
