resource "aws_vpc" "k8s-vpc" {
  cidr_block       = "172.16.0.0/16"
  enable_dns_support = true #gives you an internal domain name#
  enable_dns_hostnames = true #gives you an internal host name#
  
  tags = {
    Name        = "${local.environment}-vpc"
  }
}

 #Public subnets#
resource "aws_subnet" "public_subnet" {
  for_each = {
    "az1" = { cidr_block = "172.16.1.0/24", availability_zone = local.zone1 }
    "az2" = { cidr_block = "172.16.3.0/24", availability_zone = local.zone2 }
  }

  vpc_id                 = aws_vpc.k8s-vpc.id
  cidr_block             = each.value.cidr_block
  map_public_ip_on_launch = true
  availability_zone      = each.value.availability_zone

  tags = {
    Name                                        = "${local.environment}-public-${each.key}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

# Private subnets
resource "aws_subnet" "private_subnet" {
  for_each = {
    "az1" = { cidr_block = "172.16.2.0/24", availability_zone = local.zone1 }
    "az2" = { cidr_block = "172.16.4.0/24", availability_zone = local.zone2 }
  }

  vpc_id                 = aws_vpc.k8s-vpc.id
  cidr_block             = each.value.cidr_block
  map_public_ip_on_launch = false
  availability_zone      = each.value.availability_zone

  tags = {
    Name                                        = "${local.environment}-private-${each.key}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_internet_gateway" "k8s-igw" {
  vpc_id = aws_vpc.k8s-vpc.id

  tags = {
    Name        = "${local.environment}-igw"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "k8s_eip" {
  for_each = {
    "az1" = {}
    "az2" = {}
  }

  domain = "vpc"

  tags = {
    Name = "${local.environment}-eip-${each.key}"
  }

  depends_on = [aws_internet_gateway.k8s-igw]

}

# NAT Gateways
resource "aws_nat_gateway" "k8s_ngw" {
  for_each = {
    "az1" = aws_subnet.public_subnet["az1"]
    "az2" = aws_subnet.public_subnet["az2"]
  }

  allocation_id = aws_eip.k8s_eip[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${local.environment}-ngw-${each.key}"
  }

  depends_on = [aws_internet_gateway.k8s-igw]
}

#Public routetable#
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.k8s-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-igw.id
  }

  tags = {
    Name = "${local.environment}-public-rtb"

  }
}

 #Private Route Tables#
resource "aws_route_table" "private-rtb" {
  for_each = {
    "az1" = aws_nat_gateway.k8s_ngw["az1"]
    "az2" = aws_nat_gateway.k8s_ngw["az2"]
  }

  vpc_id = aws_vpc.k8s-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = each.value.id
  }

  tags = {
    Name = "${local.environment}-private-rtb-${each.key}"
  }
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public_subnet_assoc" {
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public-rtb.id
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "private_subnet_assoc" {
  for_each = aws_subnet.private_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private-rtb[each.key].id
}