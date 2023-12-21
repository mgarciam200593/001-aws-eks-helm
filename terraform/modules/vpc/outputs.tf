# VPC
###########################################################################
output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID of VPC"
}

output "vpc_arn" {
  value       = aws_vpc.this.arn
  description = "ARN of VPC"
}

output "vpc_cidr_block" {
  value       = aws_vpc.this.cidr_block
  description = "CIDR Block of VPC"
}

# Public Subnet
###########################################################################
output "public_subnet_ids" {
  value       = try(aws_subnet.public[*].id, null)
  description = "IDs of Public Subnets"
}

output "public_route_table_ids" {
  value       = try(aws_route_table.public[*].id, null)
  description = "IDs of Public Route Tables"
}

# Private Subnet
###########################################################################
output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "IDs of Private Subnets"
}

output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "IDs of Private Route Tables"
}

# Internet Gateway
###########################################################################
output "igw_id" {
  value       = try(aws_internet_gateway.this[0].id, null)
  description = "ID of Internet Gateway"
}

output "igw_arn" {
  value       = try(aws_internet_gateway.this[0].arn, null)
  description = "ARN of Internet Gateway"
}

# NAT Gateway
###########################################################################
output "natgw_ids" {
  value       = try(aws_nat_gateway.this[*].id, null)
  description = "IDs of NAT Gateways"
}

output "nat_public_ips" {
  value       = try(aws_eip.this[*].id, null)
  description = "IDs of Public IPs"
}