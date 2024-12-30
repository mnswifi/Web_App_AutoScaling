####################### VPC ############################

variable "cidr_block" {
  description = "The CIDR block"
  type        = string
}

variable "ingress" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))
}

variable "egress" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "enable_dns_support" {
  description = "If true, enable DNS support in the VPC"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "If true, enable DNS hostnames in the VPC"
  type        = bool
}



############################ ELB ###############################

variable "name" {
  description = "The name of the ELB"
  type        = string
}

variable "internal" {
  description = "The type of the ELB"
  type        = bool
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


variable "enable_deletion_protection" {
  description = "If true, deletion of the ELB will be protected"
  type        = bool
}


variable "load_balancer_type" {
  description = "The type of load balancer to create"
  type        = string
}

################################## Auto Scaling Group #############################

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "launch_configuration_name" {
  type        = string
  description = "Launch configuration name"
  default     = "webapp-launch-config"
}

variable "min_size" {
  type        = number
  description = "Minimum size"
}

variable "max_size" {
  type        = number
  description = "Maximum size"
}

variable "desired_capacity" {
  type        = number
  description = "Desired capacity"
}

variable "health_check_type" {
  type        = string
  description = "Health check type"
}

