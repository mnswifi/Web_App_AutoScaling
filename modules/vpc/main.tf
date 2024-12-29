locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}


//1. create VPC
resource "aws_vpc" "webapp_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "webapp-vpc"
  }
}


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

//3. Internet Gateway
resource "aws_internet_gateway" "webapp_igw" {
  vpc_id = aws_vpc.webapp_vpc.id
  tags = {
    Name = "webapp-igw"
  }
}


//4. Route table for public subnet
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


//5. Route table association with public subnet
resource "aws_route_table_association" "pub_rt_association" {
  route_table_id = aws_route_table.webapp_pub_rt.id
  count          = length(local.azs)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}


//6. Elastic IP
resource "aws_eip" "web_nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.webapp_igw]
}

//7. NAT Gateway
resource "aws_nat_gateway" "webapp-nat-gateway" {
  allocation_id = aws_eip.web_nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)
  depends_on    = [aws_internet_gateway.webapp_igw]
  tags = {
    Name = "webapp-Nat Gateway"
  }
}


//8. Route table for Private subnet
resource "aws_route_table" "webapp_private_rt" {
  depends_on = [aws_nat_gateway.webapp-nat-gateway]
  vpc_id     = aws_vpc.webapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.webapp-nat-gateway.id
  }
  tags = {
    Name = "Private subnet Route Table"
  }
}


//9. Route table association with private subnet
resource "aws_route_table_association" "private_rt_association" {
  route_table_id = aws_route_table.webapp_private_rt.id
  count          = length(local.azs)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
}


resource "aws_security_group" "webapp_sg" {
  vpc_id = aws_vpc.webapp_vpc.id
  name   = var.sg_name
  tags   = var.tags
}

resource "aws_security_group_rule" "webapp_sg_ingress" {
  for_each          = { for idx, ingress in var.ingress : idx => ingress }
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.webapp_sg.id
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

resource "aws_security_group" "dev_elb_sg" {
  name = "dev_lb_sg"
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