output "id" {
  description = "The ID of the ELB"
  value       = aws_lb.elb_web.id
}

output "arn" {
  description = "The ARN of the ELB"
  value       = aws_lb.elb_web.arn
}

output "dns_name" {
  description = "The DNS name of the ELB"
  value       = aws_lb.elb_web.dns_name
}

output "zone_id" {
  description = "The zone ID of the ELB"
  value       = aws_lb.elb_web.zone_id
}