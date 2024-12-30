output "alb_dns_name" {
  description = "value of the ALB DNS name"
  value       = module.elb.dns_name
}