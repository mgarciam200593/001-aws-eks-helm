# VPC Module

locals {
  len_public_subnets      = length(var.networks.public_subnets)
  len_private_subnets     = length(var.networks.private_subnets)
  subnet_public_tag       = var.networks.public_subnet_tags["Name"] != "" ? var.networks.public_subnet_tags["Name"] : reverse(split("-", var.name))[0]
  subnet_private_tag      = var.networks.private_subnet_tags["Name"] != "" ? var.networks.private_subnet_tags["Name"] : reverse(split("-", var.name))[0]
  route_table_public_tag  = var.networks.public_route_table_tags["Name"] != "" ? var.networks.public_route_table_tags["Name"] : "rt-${reverse(split("-", var.name))[0]}"
  route_table_private_tag = var.networks.private_route_table_tags["Name"] != "" ? var.networks.private_route_table_tags["Name"] : "rt-${reverse(split("-", var.name))[0]}"
}

# VPC
###########################################################################
resource "aws_vpc" "this" {
  cidr_block           = var.networks.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    { Name = var.name },
    var.tags
  )
}


# Public Subnet
###########################################################################
# 
resource "aws_subnet" "public" {
  count = local.len_public_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.networks.public_azs[count.index]
  cidr_block              = var.networks.public_subnets[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    { Name = "${local.subnet_public_tag}-${reverse(split("-", var.networks.public_azs[count.index]))[0]}" },
    var.tags
  )

  depends_on = [aws_vpc.this]
}

# If public subnets exist, create public route table
resource "aws_route_table" "public" {
  count = local.len_public_subnets > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    { Name = local.route_table_public_tag },
    var.tags
  )

  depends_on = [aws_subnet.public]
}

# Associate all public subnets to public route table
resource "aws_route_table_association" "public" {
  count = local.len_public_subnets

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id

  depends_on = [aws_route_table.public]
}


# Private Subnet
###########################################################################
# By default is_public is set to false and it will create private subnet(s)
resource "aws_subnet" "private" {
  count = local.len_private_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = var.networks.private_azs[count.index]
  cidr_block        = var.networks.private_subnets[count.index]

  tags = merge(
    { Name = "${local.subnet_private_tag}-${reverse(split("-", var.networks.private_azs[count.index]))[0]}" },
    var.tags
  )

  depends_on = [aws_vpc.this]
}

# If private subnets exist, create private route table
resource "aws_route_table" "private" {
  count = local.len_private_subnets > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    { Name = local.route_table_private_tag },
    var.tags
  )

  depends_on = [aws_subnet.private]
}

# Associate all private subnets to private route table
resource "aws_route_table_association" "private" {
  count = local.len_private_subnets

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id

  depends_on = [aws_route_table.private]
}


# Internet Gateway
###########################################################################
# It will create IGW per VPC if internet_gateway set to true
resource "aws_internet_gateway" "this" {
  count = local.len_public_subnets > 0 && var.networks.create_igw ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.networks.igw_tags,
    var.tags
  )

  depends_on = [aws_vpc.this]
}

# Create a route in public route table for Internet Gateway
resource "aws_route" "public_igw" {
  count = var.networks.create_igw ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  depends_on = [aws_route_table.public]
}


# NAT Gateway
###########################################################################
# It will create Elastic IP for Nat Gateway
resource "aws_eip" "this" {
  count = var.networks.create_natgw && var.networks.create_igw ? 1 : 0

  domain = "vpc"

  tags = merge(
    var.networks.eip_tags,
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

# Creation of public Nat Gateway if nat_gateway set to true
resource "aws_nat_gateway" "this" {
  count = var.networks.create_natgw && var.networks.create_igw ? 1 : 0

  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.networks.natgw_tags,
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

# Create a route in private route table for NAT gateway
resource "aws_route" "private_natgw" {
  count = var.networks.create_natgw ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id

  depends_on = [aws_route_table.private]
}
