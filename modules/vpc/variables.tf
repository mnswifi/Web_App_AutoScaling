variable "cidr_block" {
  description = "The CIDR block"
  type        = string
}

variable "cidr_blocks" {
  description = "The CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "The tags for the VPC"
  type        = map(string)
}

variable "sg_name" {
  description = "The name of the security group"
  type        = string
  default     = "dev_vpc_sg"
}

# variable "type" {
#   description = "The type of security group rule"
#   type        = string
# }

# variable "ingress" {
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
# }

# variable "egress" {
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
# }
