provider "aws" {
  region = "ap-south-1"
}

# Create a VPC
resource "aws_vpc" "demo-vpc" {
  tags = {
    Name = "demo-vpc"
  }
  cidr_block = "10.0.0.0/16"
}

# Create Subnet
resource "aws_subnet" "demo-subnet" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "demo-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-igw"
  }
}

# Create Route-table
resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }

  tags = {
    Name = "demo-rt"
  }
}

# Create route table association
resource "aws_route_table_association" "demo-rt-association" {
  subnet_id      = aws_subnet.demo-subnet.id
  route_table_id = aws_route_table.demo-rt.id
}

# Create security group
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-sg"
  }

  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

# Ec2-instance
resource "aws_instance" "ubuntu" {
  tags = {
    Name = "demo-server"
  }
  ami                    = "ami-0a1b648e2cd533174" #Ubuntu-20.04
  key_name               = "avinash-key"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.demo-subnet.id
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
}
