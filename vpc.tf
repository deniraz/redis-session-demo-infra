##############################################
# VPC
# - Base network for all resources
# - /16 CIDR to allow plenty of IP space
# - DNS support enabled for instance hostname resolution
##############################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project}-vpc" }
}

##############################################
# Internet Gateway
# - Required for public subnets to access the Internet
##############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project}-igw" }
}

##############################################
# Public Subnet A
# - Located in AZ "a"
# - Auto-assigns public IPs to instances
##############################################
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = { Name = "${var.project}-public-a" }
}

##############################################
# Public Subnet B
# - Located in AZ "b"
# - Auto-assigns public IPs to instances
# - Ensures multi-AZ redundancy
##############################################
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = { Name = "${var.project}-public-b" }
}

##############################################
# Public Route Table
# - Routes all outbound traffic to Internet Gateway
# - Associated with both public subnets
##############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id      # Internet access
  }

  tags = { Name = "${var.project}-public-rt" }
}

##############################################
# Route Table Association (Subnet A)
# - Connects Subnet A to the public route table
##############################################
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

##############################################
# Route Table Association (Subnet B)
# - Connects Subnet B to the public route table
##############################################
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

##############################################
# Outputs
# - Useful identifiers for cross-file references
##############################################
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}
