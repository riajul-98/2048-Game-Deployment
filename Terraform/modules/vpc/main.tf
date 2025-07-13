resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = local.tags
}

resource "aws_subnet" "pub_sub1" {
  vpc_id            = aws_vpc.project_vpc.id
  depends_on        = [aws_vpc.project_vpc]
  availability_zone = local.availability_zone[0]
  cidr_block        = var.subnet_cidr_blocks[0]
  tags              = local.tags
}

resource "aws_subnet" "pub_sub2" {
  vpc_id            = aws_vpc.project_vpc.id
  depends_on        = [aws_vpc.project_vpc]
  availability_zone = local.availability_zone[1]
  cidr_block        = var.subnet_cidr_blocks[1]
  tags              = local.tags
}

resource "aws_subnet" "priv_sub1" {
  vpc_id            = aws_vpc.project_vpc.id
  depends_on        = [aws_vpc.project_vpc]
  availability_zone = local.availability_zone[0]
  cidr_block        = var.subnet_cidr_blocks[2]
  tags              = local.tags
}

resource "aws_subnet" "priv_sub2" {
  vpc_id            = aws_vpc.project_vpc.id
  depends_on        = [aws_vpc.project_vpc]
  availability_zone = local.availability_zone[1]
  cidr_block        = var.subnet_cidr_blocks[3]
  tags              = local.tags
}

resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id
  tags   = local.tags
}

resource "aws_route_table" "project_pub_rt" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    cidr_block = var.route_table_cidr
    gateway_id = aws_internet_gateway.project_igw.id
  }
  tags = local.tags
}

resource "aws_route_table_association" "pub_subnet1_route_assoc" {
  route_table_id = aws_route_table.project_pub_rt.id
  subnet_id      = aws_subnet.pub_sub1.id
}

resource "aws_route_table_association" "pub_subnet2_route_assoc" {
  route_table_id = aws_route_table.project_pub_rt.id
  subnet_id      = aws_subnet.pub_sub2.id
}

resource "aws_eip" "Elastic_IP" {
  domain = "vpc"
  tags   = local.tags
}

resource "aws_nat_gateway" "project_nat" {
  subnet_id     = aws_subnet.pub_sub1.id
  allocation_id = aws_eip.Elastic_IP.id
  depends_on    = [aws_eip.Elastic_IP]
  tags          = local.tags
}

resource "aws_route_table" "project_priv_rt" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    gateway_id = aws_nat_gateway.project_nat.id
    cidr_block = var.route_table_cidr
  }
  tags = local.tags
}

resource "aws_route_table_association" "priv_subnet1_route_assoc" {
  route_table_id = aws_route_table.project_priv_rt.id
  subnet_id      = aws_subnet.priv_sub1.id
}

resource "aws_route_table_association" "priv_subnet2_route_assoc" {
  route_table_id = aws_route_table.project_priv_rt.id
  subnet_id      = aws_subnet.priv_sub2.id
}