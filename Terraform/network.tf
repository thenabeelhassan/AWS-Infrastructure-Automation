resource "aws_vpc" "DevOps-VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "DevOps-VPC"
  }
}

resource "aws_internet_gateway" "DevOps-IGW" {
  vpc_id = aws_vpc.DevOps-VPC.id

  tags = {
    Name = "MainIGW"
  }
}

resource "aws_route_table" "DevOps-PubRT" {
  vpc_id = aws_vpc.DevOps-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DevOps-IGW.id
  }

  tags = {
    Name = "DevOps-PubRT"
  }
}

resource "aws_route_table" "DevOps-PvtRT" {
  vpc_id = aws_vpc.DevOps-VPC.id

  tags = {
    Name = "DevOps-PvtRT"
  }
}

resource "aws_subnet" "Public-EC2" {
  count = 3

  vpc_id                  = aws_vpc.DevOps-VPC.id
  cidr_block              = "10.0.10${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(["me-south-1a", "me-south-1b", "me-south-1c"], count.index)

  tags = {
    Name = "DevOps-Pub-EC2-${count.index + 1}"
  }
}

resource "aws_subnet" "Private-EC2" {
  count = 3

  vpc_id                  = aws_vpc.DevOps-VPC.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(["me-south-1a", "me-south-1b", "me-south-1c"], count.index)

  tags = {
    Name = "DevOps-Pvt-EC2-${count.index + 1}"
  }
}


resource "aws_subnet" "Private-RDS" {
  count = 3

  vpc_id                  = aws_vpc.DevOps-VPC.id
  cidr_block              = "10.0.2${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(["me-south-1a", "me-south-1b", "me-south-1c"], count.index)

  tags = {
    Name = "DevOps-Pvt-RDS-${count.index + 1}"
  }
}

resource "aws_route_table_association" "Public-EC2" {
  count = 3

  subnet_id      = aws_subnet.Public-EC2[count.index].id
  route_table_id = aws_route_table.DevOps-PubRT.id
}

resource "aws_route_table_association" "Private-EC2" {
  count = 3

  subnet_id      = aws_subnet.Private-EC2[count.index].id
  route_table_id = aws_route_table.DevOps-PvtRT.id
}

resource "aws_route_table_association" "Private-RDS" {
  count = 3

  subnet_id      = aws_subnet.Private-RDS[count.index].id
  route_table_id = aws_route_table.DevOps-PvtRT.id
}