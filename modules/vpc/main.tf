locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}


####################### VPC ############################
resource "aws_vpc" "webapp_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = "webapp-vpc"
  }
}

####################### Subnets ############################	
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.webapp_vpc.id
  count             = length(local.azs)
  cidr_block        = cidrsubnet(aws_vpc.webapp_vpc.cidr_block, 8, count.index + 1)
  availability_zone = element(local.azs, count.index)
  tags = {
    Name = "webapp Public subnet ${count.index + 1}"
  }
}


resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.webapp_vpc.id
  count             = length(local.azs)
  cidr_block        = cidrsubnet(aws_vpc.webapp_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(local.azs, count.index)
  tags = {
    Name = "webapp Private subnet ${count.index + 1}"
  }
}

####################### Internet Gateway ############################
resource "aws_internet_gateway" "webapp_igw" {
  vpc_id = aws_vpc.webapp_vpc.id
  tags = {
    Name = "webapp-igw"
  }
}


####################### Route Table ############################
resource "aws_route_table" "webapp_pub_rt" {
  vpc_id = aws_vpc.webapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp_igw.id
  }
  tags = {
    Name = "Public subnet Route Table"
  }
}


# Route table association with public subnet
resource "aws_route_table_association" "pub_rt_association" {
  route_table_id = aws_route_table.webapp_pub_rt.id
  count          = length(local.azs)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}


# Route table for private subnet
resource "aws_route_table" "webapp_private_rt" {
  count      = length(local.azs)
  depends_on = [aws_nat_gateway.webapp-nat-gateway]
  vpc_id     = aws_vpc.webapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.webapp-nat-gateway[*].id, count.index)
  }
  tags = {
    Name = "Private subnet Route Table ${count.index + 1}"
  }
}


# Route table association with private subnet
resource "aws_route_table_association" "private_rt_association" {
  count          = length(local.azs)
  route_table_id = element(aws_route_table.webapp_private_rt[*].id, count.index)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
}

######################## Elastic IP and NAT Gateway ############################
# Elastic IP for NAT Gateway
resource "aws_eip" "web_nat_eip" {
  count      = length(local.azs)
  domain     = "vpc"
  depends_on = [aws_internet_gateway.webapp_igw]
}

# NAT Gateway
resource "aws_nat_gateway" "webapp-nat-gateway" {
  count         = length(local.azs)
  allocation_id = element(aws_eip.web_nat_eip[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)
  depends_on    = [aws_internet_gateway.webapp_igw]
  tags = {
    Name = "webapp-Nat Gateway ${count.index + 1}"
  }
}

####################### Security Group ############################
# Security Group for Webapp
resource "aws_security_group" "webapp_sg" {
  vpc_id = aws_vpc.webapp_vpc.id
  name   = var.sg_name
  tags   = var.tags
}

resource "aws_security_group_rule" "webapp_sg_ingress" {
  for_each                 = { for idx, ingress in var.ingress : idx => ingress }
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.webapp_sg.id
  source_security_group_id = aws_security_group.dev_elb_sg.id
}

resource "aws_security_group_rule" "webapp_sg_egress" {
  type              = "egress"
  for_each          = { for idx, egress in var.egress : idx => egress }
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.webapp_sg.id
  cidr_blocks       = each.value.cidr_blocks
}

# Security Group for Dev ELB
resource "aws_security_group" "dev_elb_sg" {
  name = "dev_lb_sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.webapp_vpc.id
  tags   = var.tags
}