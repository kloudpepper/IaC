######################
### Network Module ###
######################

# Data Availability Zones
data "aws_availability_zones" "available" {
    state = "available"
}

# Create VPC
resource "aws_vpc" "vpc" {
    cidr_block              = var.vpc_CIDR
    enable_dns_support      = "true"
    enable_dns_hostnames    = "true"
    instance_tenancy        = "default"
    
    tags = {
        Name                = "${var.environmentName}-vpc"
    }
}

#Create Private Subnet 1
resource "aws_subnet" "PrivateSubnet1" {
    depends_on              = [aws_vpc.vpc]
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.private_subnet_1_CIDR
    map_public_ip_on_launch = "false"
    availability_zone       = data.aws_availability_zones.available.names[0]
    tags = {
        Name                = "${var.environmentName}-PrivateSubnet1"
    }
}

#Create Private Subnet 2
resource "aws_subnet" "PrivateSubnet2" {
    depends_on              = [aws_vpc.vpc]
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.private_subnet_2_CIDR
    map_public_ip_on_launch = "false"
    availability_zone       = data.aws_availability_zones.available.names[1]
    tags = {
        Name                = "${var.environmentName}-PrivateSubnet2"
    }
}

#Create Reserved Subnet
resource "aws_subnet" "ReservedSubnet" {
    depends_on              = [aws_vpc.vpc]
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.reserved_subnet_CIDR
    map_public_ip_on_launch = var.create_igw
    availability_zone       = data.aws_availability_zones.available.names[2]
    tags = {
        Name                = "${var.environmentName}-ReservedSubnet"
    }
}

# Create Internet Gateway (Optional)
resource "aws_internet_gateway" "igw" {
    count = var.create_igw ? 1 : 0
    depends_on              = [aws_vpc.vpc]
    vpc_id                  = aws_vpc.vpc.id
    tags = {
        Name                = "${var.environmentName}-igw"
    }
}

# Create Transit Gateway Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "TransitGatewayAttachment" {
    count = var.create_transit_gateway_attachment ? 1 : 0
    depends_on              = [aws_subnet.PrivateSubnet1, aws_subnet.PrivateSubnet2]
    subnet_ids              = [aws_subnet.PrivateSubnet1.id, aws_subnet.PrivateSubnet2.id]
    transit_gateway_id      = var.transit_gateway_ID
    vpc_id                  = aws_vpc.vpc.id
    tags = {
        Name                = "${var.environmentName}-transit-attachment"
    }
}

# Create Private Route Table
resource "aws_route_table" "PrivateRouteTable" {
    depends_on              = [aws_vpc.vpc]
    vpc_id                  = aws_vpc.vpc.id
    tags = {
        Name                = "${var.environmentName}-PrivateRouteTable"
    }
}

# Create Reserved Route Table
resource "aws_route_table" "ReservedRouteTable" {
    depends_on              = [aws_vpc.vpc]
    vpc_id                  = aws_vpc.vpc.id
    tags = {
        Name                = "${var.environmentName}-ReservedRouteTable"
    }
}

# Create Private Subnet 1 Route Table Association
resource "aws_route_table_association" "PrivateSubnet1RouteTableAssociation"{
    depends_on              = [aws_subnet.PrivateSubnet1, aws_route_table.PrivateRouteTable]
    subnet_id               = aws_subnet.PrivateSubnet1.id
    route_table_id          = aws_route_table.PrivateRouteTable.id
}

# Create Private Subnet 2 Route Table Association
resource "aws_route_table_association" "PrivateSubnet2RouteTableAssociation"{
    depends_on              = [aws_subnet.PrivateSubnet2, aws_route_table.PrivateRouteTable]
    subnet_id               = aws_subnet.PrivateSubnet2.id
    route_table_id          = aws_route_table.PrivateRouteTable.id
}

# Create Reserved Subnet Route Table Association
resource "aws_route_table_association" "ReservedSubnetRouteTableAssociation"{
    depends_on              = [aws_subnet.ReservedSubnet, aws_route_table.ReservedRouteTable]
    subnet_id               = aws_subnet.ReservedSubnet.id
    route_table_id          = aws_route_table.ReservedRouteTable.id
}

# Create Route To Transit Gateway
resource "aws_route" "RouteToTransitGateway" {
    count = var.create_transit_gateway_attachment ? 1 : 0
    depends_on              = [aws_route_table.PrivateRouteTable]
    route_table_id          = aws_route_table.PrivateRouteTable.id
    destination_cidr_block  = "0.0.0.0/0"
    transit_gateway_id      = var.transit_gateway_ID
}

# Create Route To Internet Gateway (Optional)
resource "aws_route" "RouteToInternetGateway" {
    count                     = var.create_igw ? 1 : 0
    depends_on                = [aws_route_table.ReservedRouteTable]
    route_table_id            = aws_route_table.ReservedRouteTable.id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id                = aws_internet_gateway.igw[0].id
}