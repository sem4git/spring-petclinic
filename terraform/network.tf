resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Demo-VPC"
  }
}

resource "aws_subnet" "demo_pub_subnet_a" {
  vpc_id                  = aws_vpc.demo_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Demo-Public-Subnet-AZ-A"
  }
}
resource "aws_subnet" "demo_pub_subnet_b" {
  vpc_id                  = aws_vpc.demo_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Demo-Public-Subnet-AZ-B"
  }
}
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "Demo-IGW"
  }
}
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "Demo-Public-Route"
  }
}
resource "aws_route_table_association" "rta_a_pub" {
  subnet_id      = aws_subnet.demo_pub_subnet_a.id
  route_table_id = aws_route_table.pub.id

}
resource "aws_route_table_association" "rta_b_pub" {
  subnet_id      = aws_subnet.demo_pub_subnet_b.id
  route_table_id = aws_route_table.pub.id

}
resource "aws_subnet" "demo_private_subnet_a" {
  vpc_id            = aws_vpc.demo_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.11.0/24"

  tags = {
    Name = "Demo-Private-Subnet-AZ-A"
  }
}
resource "aws_subnet" "demo_private_subnet_b" {
  vpc_id            = aws_vpc.demo_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.21.0/24"

  tags = {
    Name = "Demo-Private-Subnet-AZ-B"
  }
}

resource "aws_nat_gateway" "demo_nat_gw_a" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.demo_private_subnet_a.id
}
resource "aws_nat_gateway" "demo_nat_gw_b" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.demo_private_subnet_b.id
}
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.demo_nat_gw_a.id
  }

  tags = {
    Name = "Demo-Private-Route-A"
  }
}
resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.demo_nat_gw_b.id
  }

  tags = {
    Name = "Demo-Private-Route-B"
  }
}
resource "aws_route_table_association" "rta_private_a" {
  subnet_id      = aws_subnet.demo_private_subnet_a.id
  route_table_id = aws_route_table.private_a.id

}
resource "aws_route_table_association" "rta_private_b" {
  subnet_id      = aws_subnet.demo_private_subnet_b.id
  route_table_id = aws_route_table.private_b.id

}