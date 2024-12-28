variable "asg_id" {
  description = "The ID of the Auto Scaling Group to attach to the ELB"
  type        = string
}

variable "name" {
  description = "The name of the ELB"
  type        = string
}

variable "tg_name" {
  description = "The Dev ELB Target group name"
  type        = string
  default     = "Dev-Tg"
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs"
  type        = list(string)
}

variable "listener" {
  description = "The listener configuration"
  type = list(object({
    lb_port     = number
    lb_protocol = string
  }))
}


variable "target_grp" {
  description = "The listener configuration"
  type = list(object({
    instance_port     = number
    instance_protocol = string
  }))
}


variable "internal" {
  description = "If true, the ELB will be internal"
  type        = bool
}

variable "load_balancer_type" {
  description = "The type of load balancer to create"
  type        = string
}

variable "security_group_ids" {
  description = "The security group ID"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the ELB will be protected"
  type        = bool
}

variable "tags" {
  description = "The tags to apply to the ELB"
  type        = map(string)
}

