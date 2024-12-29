resource "aws_autoscaling_group" "webapp_asg" {
  name                      = "ASG-dev"
  vpc_zone_identifier       = var.subnet_ids
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = var.health_check_type
  health_check_grace_period = 300
  force_delete              = true
  lifecycle {
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.dev_temp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "webApp-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "webapp_asg_policy" {
  name                   = "webapp-asg-test"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 0
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_launch_template" "dev_temp" {
  name                   = var.launch_configuration_name
  image_id               = var.ami_id
  instance_type          = var.instance_type
  # vpc_security_group_ids = var.security_group_ids
  user_data              = var.user_data

  network_interfaces {
    associate_public_ip_address = false
    security_groups = var.security_group_ids
    # subnet_id = var.subnet_ids[*]
  }
}
