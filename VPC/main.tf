resource "aws_vpc" "task-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true 
  tags = {
    Name = "task-vpc"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.task-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.av-azs.names[0]
  tags = {
    Name = "private-1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.task-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.av-azs.names[1]
  tags = {
    Name = "private-2"
  }
}

resource "aws_subnet" "private-3" {
  vpc_id            = aws_vpc.task-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.av-azs.names[2]
  tags = {
    Name = "private-3"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.av-azs.names[0]
  tags = {
    Name = "public-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.av-azs.names[1]
  tags = {
    Name = "public-2"
  }
}

resource "aws_subnet" "public-3" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.103.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.av-azs.names[2]
  tags = {
    Name = "public-3"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.task-vpc.id

  tags = {
    Name = "task-igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.task-vpc.id

  tags = {
    Name = "public-rt"
  }
}

resource "aws_main_route_table_association" "mainflag" {
  vpc_id         = aws_vpc.task-vpc.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-ass1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-ass2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-ass3" {
  subnet_id      = aws_subnet.public-3.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route" "rigw" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.task-vpc.id

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private-ass1" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-ass2" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-ass3" {
  subnet_id      = aws_subnet.private-3.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
  domain     = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-1.id
}

resource "aws_route" "rngw" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}