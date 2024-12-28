output "asg_id" {
  description = "The Auto Scaling Group id"
  value       = aws_autoscaling_group.webapp_asg.id
}