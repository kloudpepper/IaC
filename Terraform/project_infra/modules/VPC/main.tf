######################
### Network Module ###
######################

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnet_cidr_blocks = [for i in range(0, var.public_Subnets + var.private_Subnets) : cidrsubnet(var.vpc_CIDR, 4, i)]
}


# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_CIDR
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "${var.environment_Name}-vpc"
  }
}


# Create Public and Private Subnets
resource "aws_subnet" "public_subnets" {
  count                   = var.public_Subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(local.subnet_cidr_blocks, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index % var.availability_Zones)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment_Name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.private_Subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(local.subnet_cidr_blocks, count.index + var.availability_Zones)
  availability_zone = element(data.aws_availability_zones.available.names, count.index % var.availability_Zones)
  tags = {
    Name = "${var.environment_Name}-private-subnet-${count.index + 1}"
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  count      = var.public_Subnets != 0 ? 1 : 0
  depends_on = [aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment_Name}-igw"
  }
}


# Create Simple Nat Gateway (1AZ)
resource "aws_eip" "eip_1AZ" {
  count = var.create_NatGateway_1AZ ? 1 : 0
  tags = {
    Name = "${var.environment_Name}-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway_1AZ" {
  count         = var.create_NatGateway_1AZ ? 1 : 0
  depends_on    = [aws_internet_gateway.igw]
  allocation_id = aws_eip.eip_1AZ[count.index].id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "${var.environment_Name}-ngw"
  }
}


# Create Nat Gateway HA (1perAZ)
resource "aws_eip" "eip_1perAZ" {
  count = var.create_NatGateway_1perAZ ? var.availability_Zones : 0
  tags = {
    Name = "${var.environment_Name}-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gateway_1perAZ" {
  count         = var.create_NatGateway_1perAZ ? var.availability_Zones : 0
  depends_on    = [aws_internet_gateway.igw]
  allocation_id = aws_eip.eip_1perAZ[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)

  tags = {
    Name = "${var.environment_Name}-ngw-${count.index + 1}"
  }
}


# Create Transit Gateway
resource "aws_ec2_transit_gateway" "transit_gateway" {
  count                           = var.create_TransitGateway ? 1 : 0
  description                     = "Transit Gateway"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"

  tags = {
    Name = "${var.environment_Name}-tgw"
  }

}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_attachment" {
  count              = var.create_TransitGateway ? 1 : 0
  depends_on         = [aws_subnet.private_subnets]
  subnet_ids         = aws_subnet.private_subnets[*].id
  vpc_id             = aws_vpc.vpc.id
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  tags = {
    Name = "${var.environment_Name}-tgw-attachment"
  }
}


# Create Public and Private Route Tables
resource "aws_route_table" "public_route_table" {
  count  = var.public_Subnets != 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = {
    Name = "${var.environment_Name}-public-route-table"
  }
}

resource "aws_route_table" "private_route_tables" {
  count  = var.private_Subnets != 0 ? var.private_Subnets : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment_Name}-private-route-table-${count.index + 1}"
  }
}


# Create Public Subnets Route Table Association
resource "aws_route_table_association" "public_subnets_route_table_association" {
  count          = var.public_Subnets
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table[0].id
}

# Create Private Subnets Route Tables Association
resource "aws_route_table_association" "private_subnets_route_table_association" {
  count          = var.private_Subnets
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}


# Create routes to Nat Gateway or Transit Gateway
resource "aws_route" "route_to_nat_gateway" {
  count                  = var.create_NatGateway_1AZ || var.create_NatGateway_1perAZ ? var.private_Subnets : 0
  route_table_id         = aws_route_table.private_route_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.create_NatGateway_1AZ ? aws_nat_gateway.nat_gateway_1AZ[0].id : var.create_NatGateway_1perAZ ? aws_nat_gateway.nat_gateway_1perAZ[count.index % var.availability_Zones].id : 0
}

resource "aws_route" "route_to_transit_gateway" {
  count                  = var.create_TransitGateway ? var.private_Subnets : 0
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment]
  route_table_id         = aws_route_table.private_route_tables[count.index].id
  destination_cidr_block = var.route_TransitGateway
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway[0].id
}