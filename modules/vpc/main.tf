locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}


resource "aws_vpc" "webapp_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

resource "aws_internet_gateway" "webapp_igw" {
  vpc_id = aws_vpc.webapp_vpc.id
  tags   = var.tags
}

resource "aws_route_table" "pub_route" {
  vpc_id = aws_vpc.webapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp_igw.id
  }

  tags = var.tags
}

resource "aws_subnet" "pub_subnet" {
  count                   = length(local.azs)
  availability_zone       = local.azs[count.index]
  vpc_id                  = aws_vpc.webapp_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags                    = var.tags
}

resource "aws_route_table_association" "pub_rt_association" {
  count          = length(aws_subnet.pub_subnet)
  subnet_id      = aws_subnet.pub_subnet[count.index].id
  route_table_id = aws_route_table.pub_route.id
}

resource "aws_subnet" "webapp_subnet_private" {
  count             = length(local.azs)
  availability_zone = local.azs[count.index]
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 2)
  tags              = var.tags
}

# resource "aws_security_group" "webapp_sg" {
#   vpc_id = aws_vpc.webapp_vpc.id
#   name   = var.sg_name
#   tags   = var.tags
# }

# resource "aws_security_group_rule" "webapp_sg_ingress" {
#   for_each          = { for idx, ingress in var.ingress : idx => ingress }
#   type              = "ingress"
#   from_port         = each.value.from_port
#   to_port           = each.value.to_port
#   protocol          = each.value.protocol
#   security_group_id = aws_security_group.webapp_sg.id
#   cidr_blocks       = each.value.cidr_blocks
# }

# resource "aws_security_group_rule" "webapp_sg_egress" {
#   type              = "egress"
#   for_each          = { for idx, egress in var.egress : idx => egress }
#   from_port         = each.value.from_port
#   to_port           = each.value.to_port
#   protocol          = each.value.protocol
#   security_group_id = aws_security_group.webapp_sg.id
#   cidr_blocks       = each.value.cidr_blocks
# }

resource "aws_security_group" "webapp_sg" {
  name = "learn-asg-terramino-instance"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.webapp_vpc.id
  tags = var.tags
}