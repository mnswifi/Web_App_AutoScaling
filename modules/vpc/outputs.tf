
output "webapp_vpc_id" {
  description = "The VPC id of the webapp"
  value       = aws_vpc.webapp_vpc.id
}

output "webapp_private_subnet_ids" {
  description = "The private subnet ids for webapp"
  value       = [for subnet in aws_subnet.private_subnet : subnet.id]
}

output "webapp_public_subnet_ids" {
  description = "The public subnet ids for ELB"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "webapp_sg_ids" {
  description = "The security group id of the webapp"
  value       = aws_security_group.webapp_sg.id
}


output "dev_elb_sg" {
  description = "The security group id of the ELB"
  value       = aws_security_group.dev_elb_sg.id
}

