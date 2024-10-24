# Create VPC
resource "aws_vpc" "k8s-vpc-west-2" {
     provider = aws.us-west-2
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    name = "${var.environment}-vpc"
  }
}

# Create Subnet
resource "aws_subnet" "publicsubnet" {
  provider = aws.us-west-2
  vpc_id     = aws_vpc.k8s-vpc-west-2.id
  cidr_block = "172.16.1.0/24"
  availability_zone = var.zone1_west
  map_public_ip_on_launch = true

 tags = {
    Name                                                = "publicsubnet1-us-west-2"
    "kubernetes.io/cluster/k8s-cluster-production"      = "shared"
    "kubernetes.io/role/elb"                            = "1"
  }
}

resource "aws_subnet" "publicsubnet2" {
  provider = aws.us-west-2
  vpc_id     = aws_vpc.k8s-vpc-west-2.id
  cidr_block = "172.16.3.0/24"
  availability_zone = var.zone2_west
  map_public_ip_on_launch = true

  tags = {
    Name                                              = "publicsubnet2-us-west-2"
    "kubernetes.io/cluster/k8s-cluster-production"    = "shared"
    "kubernetes.io/role/elb"                          = "1"
  }
}

resource "aws_subnet" "privatesubnet1" {
  provider = aws.us-west-2
  vpc_id     = aws_vpc.k8s-vpc-west-2.id
  cidr_block = var.private_subnet1_cidr  #"172.16.2.0/24"
  availability_zone = var.zone1_west
  map_public_ip_on_launch = false

  tags = {
    Name                                              = "privatesubnet1-us-west-2"
    "kubernetes.io/cluster/k8s-cluster-production"    = "shared"
    "kubernetes.io/role/elb"                          = "1"
  }
}

resource "aws_subnet" "privatesubnet2" {
  provider = aws.us-west-2
  vpc_id     = aws_vpc.k8s-vpc-west-2.id
  cidr_block = var.private_subnet2_cidr #"172.16.4.0/24"
  availability_zone = var.zone2_west
  map_public_ip_on_launch = false

   tags = {
    Name                                                = "privatesubnet2-us-west-2"
    "kubernetes.io/cluster/k8s-cluster-production"      = "shared"
    "kubernetes.io/role/elb"                            = "1"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "publicig" {
  provider = aws.us-west-2
  vpc_id = aws_vpc.k8s-vpc-west-2.id

   tags = {
    Name        = "${var.environment}-igw"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "k8s_eip" {
  provider = aws.us-west-2
  for_each = {
    "az1" = {}
    "az2" = {}
  }

  domain = "vpc"

  tags = {
    Name = "${var.environment}-eip-${each.key}"
  }

  depends_on = [aws_internet_gateway.publicig]

}


# NAT Gateway for az1
resource "aws_nat_gateway" "k8s_ngw_az1" {
  provider = aws.us-west-2
  allocation_id = aws_eip.k8s_eip["az1"].id
  subnet_id     = aws_subnet.publicsubnet.id  # Reference to subnet in az1

  tags = {
    Name = "${var.environment}-ngw-az1"
  }

  depends_on = [aws_internet_gateway.publicig]
}

# NAT Gateway for az2
resource "aws_nat_gateway" "k8s_ngw_az2" {
  provider = aws.us-west-2
  allocation_id = aws_eip.k8s_eip["az2"].id
  subnet_id     = aws_subnet.publicsubnet2.id  # Reference to subnet in az2

  tags = {
    Name = "${var.environment}-ngw-az2"
  }

  depends_on = [aws_internet_gateway.publicig]
}





# Create Route Table
resource "aws_route_table" "routeigw" {
  provider = aws.us-west-2
  vpc_id = aws_vpc.k8s-vpc-west-2.id 

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.publicig.id
  }

  tags = {
    Name = "${var.environment}-routetable"
  }
}


resource "aws_route_table" "routeprivate" {
  provider = aws.us-west-2
  vpc_id = aws_vpc.k8s-vpc-west-2.id 

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.k8s_ngw_az1.id
  }

  tags = {
    Name = "${var.environment}-private-routetable"
  }
}

resource "aws_route_table" "routeprivate2" {
  provider = aws.us-west-2
  vpc_id = aws_vpc.k8s-vpc-west-2.id 

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.k8s_ngw_az2.id
  }

  tags = {
    Name = "${var.environment}-private-routetable2"
  }
}


# Associate public Subnet with Route Table in az1
resource "aws_route_table_association" "publicsubnet_asst" {
  provider = aws.us-west-2
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.routeigw.id
}

# Associate public Subnet with Route Table in az2
resource "aws_route_table_association" "publicsubnet2_asst" {
  provider = aws.us-west-2
  subnet_id      = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.routeigw.id
}

resource "aws_route_table_association" "privatesubnet_asst" {
  provider = aws.us-west-2
  subnet_id      = aws_subnet.privatesubnet1.id
  route_table_id = aws_route_table.routeprivate.id
}

# Associate public Subnet with Route Table in az2
resource "aws_route_table_association" "privatesubnet2_asst" {
  provider = aws.us-west-2
  subnet_id      = aws_subnet.privatesubnet2.id
  route_table_id = aws_route_table.routeprivate2.id
}