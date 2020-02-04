resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"

  tags = { 
	Name        = "opscool_mid_project"
	Description = "Vpc For Opscool Mid project"
  }
}

resource "aws_subnet" "private" {
  count             =  length(var.availability_zone)
  vpc_id            = "${aws_vpc.vpc1.id}"
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zone, count.index)

  tags = {
    Name        = "priavte_sub ${count.index+1}"
	  Description = "Priavte subnet ${count.index+1}"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.availability_zone)
  vpc_id                  = "${aws_vpc.vpc1.id}"
  cidr_block              = element(var.public_subnets, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(var.availability_zone, count.index)

  tags = {
    Name        = "public_sub ${count.index+1}"
	  Description = "Public subnet ${count.index+1}"
  }
}

resource "aws_internet_gateway" "web-igw" {
  vpc_id = "${aws_vpc.vpc1.id}"

  tags = {
	  Name        = "vpc1-igw" 
	  Description = "Internet gateway for lesson 3"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
	Name        = "public-rtb"
	Description = "Route table for public subnets"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = var.egress_cidr_blocks
  gateway_id             = aws_internet_gateway.web-igw.id
}

resource "aws_route_table_association" "rta-public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table" "private_rtb" {
  vpc_id      = aws_vpc.vpc1.id
  count       = length(aws_subnet.private)
  tags        = {
	Name        = "private-rtb"
	Description = "Route table for private subnets"
  }
}

resource "aws_route" "private_route" {
  count                  = length(aws_subnet.private)
  route_table_id         = element(aws_route_table.private_rtb.*.id, count.index)
  destination_cidr_block = var.egress_cidr_blocks
  nat_gateway_id         = element(aws_nat_gateway.private_natgw.*.id, count.index)

}

resource "aws_route_table_association" "rta-private" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_rtb.*.id, count.index)
}

resource "aws_nat_gateway" "private_natgw" {
  count         = length(aws_subnet.private)
  allocation_id = element(aws_eip.nat_gw.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
}

resource "aws_eip" "nat_gw" {
  count    = length(var.availability_zone)
  vpc      = true

  tags = {
	Name        = "nat-gw ${count.index+1}"
	Description = "Elastic ips for nat gateway, 1 per az"
  }
}