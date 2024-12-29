# output "webapp_vpc_id" {
#   description = "The VPC id of the webapp"
#   value       = aws_vpc.webapp_vpc.id
# }

# output "webapp_private_subnet_ids" {
#   description = "The private subnet id for webapp"
#   # value       = [for subnet in aws_subnet.webapp_subnet : subnet.id]
#   value = aws_subnet.webapp_subnet_private.id
# }

# output "webapp_public_subnet_ids" {
#   description = "The public subnet for ELB"
#   value = aws_subnet.pub_subnet.id
# }

# output "webapp_sg_ids" {
#   description = "The security group id of the webapp"
#   value       = aws_security_group.webapp_sg.id
# }

output "webapp_vpc_id" {
  description = "The VPC id of the webapp"
  value       = aws_vpc.webapp_vpc.id
  # value = aws_vpc.custom_vpc.id
}

output "webapp_private_subnet_ids" {
  description = "The private subnet ids for webapp"
  # value       = [for subnet in aws_subnet.webapp_subnet_private : subnet.id]
  value = [for subnet in aws_subnet.private_subnet : subnet.id ]
}

output "webapp_public_subnet_ids" {
  description = "The public subnet ids for ELB"
  # value       = [for subnet in aws_subnet.pub_subnet : subnet.id]
  value = [for subnet in aws_subnet.public_subnet : subnet.id ]
}

output "webapp_sg_ids" {
  description = "The security group id of the webapp"
  value       = aws_security_group.webapp_sg.id
}


output "dev_elb_sg" {
  description = "The security group id of the ELB"
  value       = aws_security_group.dev_elb_sg.id  
}


# output "asg_sg" {
#   value = aws_security_group.Asg_instance.id
# }