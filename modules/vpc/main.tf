# Unity VPC Module
# Creates a VPC with public and private subnets across multiple AZs

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Local values for consistent naming and tagging
locals {
  tags = merge(var.tags, {
    Module      = "unity-vpc"
    Environment = var.environment
    Project     = var.project
  })

  # Calculate subnet CIDRs
  public_subnet_cidrs  = [for i in range(length(var.availability_zones)) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(length(var.availability_zones)) : cidrsubnet(var.vpc_cidr, 8, i + 10)]
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  count = var.create_igw ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-public-${count.index + 1}"
    Type = "public"
    AZ   = var.availability_zones[count.index]
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-private-${count.index + 1}"
    Type = "private"
    AZ   = var.availability_zones[count.index]
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  domain = "vpc"

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# Route Tables - Public
resource "aws_route_table" "public" {
  count = var.create_igw ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-public-rt"
    Type = "public"
  })
}

# Public Route - Internet Gateway
resource "aws_route" "public_internet_gateway" {
  count = var.create_igw ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id

  timeouts {
    create = "5m"
  }
}

# Route Table Associations - Public
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = var.create_igw ? aws_route_table.public[0].id : aws_vpc.main.default_route_table_id
}

# Route Tables - Private
resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"
    Type = "private"
    AZ   = var.availability_zones[count.index]
  })
}

# Private Routes - NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id

  timeouts {
    create = "5m"
  }
}

# Route Table Associations - Private
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# VPN Gateway
resource "aws_vpn_gateway" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id          = aws_vpc.main.id
  amazon_side_asn = var.amazon_side_asn

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-vpn-gw"
  })
}

# VPN Gateway Route Table Propagation
resource "aws_vpn_gateway_route_propagation" "public" {
  count = var.enable_vpn_gateway && var.propagate_public_route_tables_vgw && var.create_igw ? 1 : 0

  vpn_gateway_id = aws_vpn_gateway.main[0].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_vpn_gateway_route_propagation" "private" {
  count = var.enable_vpn_gateway && var.propagate_private_route_tables_vgw ? length(aws_route_table.private) : 0

  vpn_gateway_id = aws_vpn_gateway.main[0].id
  route_table_id = aws_route_table.private[count.index].id
}

# Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # Remove default rules
  ingress = []
  egress  = []

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-default-sg"
  })
}

# VPC Flow Logs
resource "aws_flow_log" "vpc" {
  count = var.enable_flow_log ? 1 : 0

  iam_role_arn    = var.flow_log_iam_role_arn
  log_destination = var.flow_log_destination_arn
  traffic_type    = var.flow_log_traffic_type
  vpc_id          = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-flow-log"
  })
}

# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  vpc_endpoint_type = "Gateway"

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-s3-endpoint"
  })
}

resource "aws_vpc_endpoint_route_table_association" "s3_private" {
  count = var.enable_s3_endpoint ? length(aws_route_table.private) : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.private[count.index].id
}

resource "aws_vpc_endpoint_route_table_association" "s3_public" {
  count = var.enable_s3_endpoint && var.create_igw ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public[0].id
}

# DynamoDB VPC Endpoint
resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.dynamodb"
  vpc_endpoint_type = "Gateway"

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-dynamodb-endpoint"
  })
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_private" {
  count = var.enable_dynamodb_endpoint ? length(aws_route_table.private) : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = aws_route_table.private[count.index].id
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_public" {
  count = var.enable_dynamodb_endpoint && var.create_igw ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = aws_route_table.public[0].id
}

# Data sources
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}