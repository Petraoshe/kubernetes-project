# Create KeyPair 
resource "tls_private_key" "test-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "test-key" {
  content  = tls_private_key.test-key.private_key_pem
  filename = "test-key"
  provisioner "local-exec" {
    command = "chmod 400 test-key"
  }
}

resource "aws_key_pair" "test-key" {
  key_name   = "test-key"
  public_key = tls_private_key.test-key.public_key_openssh
}
# Create a VPC
resource "aws_vpc" "KMS_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "KMS_vpc"
  }
}

# Create Public Subnet 1 (attach VPC, CIDR block and AZ1)
resource "aws_subnet" "KMS_Pub_SN1" {
  vpc_id            = aws_vpc.KMS_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "KMS_Pub_SN1"
  }
}
# Create Public Subnet 2 (attach VPC, CIDR block and AZ2)
resource "aws_subnet" "KMS_Pub_SN2" {
  vpc_id            = aws_vpc.KMS_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "KMS_Pub_SN2"
  }
}

# Create Internet Gateway (attach to vpc)
resource "aws_internet_gateway" "KMS_IGW" {
  vpc_id = aws_vpc.KMS_vpc.id

  tags = {
    Name = "KMS_IGW"
  }
}

# Create Public Route Table (attach vpc, allow all possible IPV4 addresses, route traffic to internet gateway)
resource "aws_route_table" "KMS_Pub_RT" {
  vpc_id = aws_vpc.KMS_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.KMS_IGW.id
  }

  tags = {
    Name = "KMS_Pub_RT"
  }
}

# Create Route Table Association for public subnet 1(attach public subnet 1 and associate to public route table)
resource "aws_route_table_association" "KMS_Pub_RT_ASS_SN1" {
  subnet_id      = aws_subnet.KMS_Pub_SN1.id
  route_table_id = aws_route_table.KMS_Pub_RT.id
}
# Create Route Table Association for public subnet 2(attach public subnet 2 and associate to public route table)
resource "aws_route_table_association" "KMS_Pub_RT_ASS_SN2" {
  subnet_id      = aws_subnet.KMS_Pub_SN2.id
  route_table_id = aws_route_table.KMS_Pub_RT.id
}

# Security Group

# Create Frontend Security
resource "aws_security_group" "KMS_Frontend_SG" {
  name        = "KMS_Frontend_SG"
  description = "Frontend_SG"
  vpc_id      = aws_vpc.KMS_vpc.id

  ingress {
    description = "Open to All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Proxy from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Server from VPC"
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "KMS_Frontend_SG"
  }
}

resource "aws_instance" "Jenkins" {
  ami                         = "ami-03542b5588cd0e6b3"
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.test-key.key_name
  subnet_id                   = aws_subnet.KMS_Pub_SN1.id
  vpc_security_group_ids      = [aws_security_group.KMS_Frontend_SG.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install java-11-openjdk-devel git -y
    sudo yum install wget -y
    sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import http://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum update -y
    sudo yum install jenkins -y
    sudo systemctl start jenkins
    EOF

  tags = {
    Name = "Jenkins"
  }
}