provider "aws" {
  version = "~> 2.0"
  region  = "ap-northeast-1"
}

resource "aws_vpc" "sample_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "horiken_sample_vpc"
  }
}

resource "aws_subnet" "sample_public_web" {
  vpc_id = aws_vpc.sample_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "horiken_sample_public_web"
  }
}

resource "aws_internet_gateway" "sample_gw" {
  vpc_id = aws_vpc.sample_vpc.id

  tags = {
    Name = "horiken_igw"
  }
}

resource "aws_route_table" "sample_public_rtb" {
  vpc_id = aws_vpc.sample_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sample_gw.id
  }

  tags = {
    Name = "horiken_rtb"
  }
}

resource "aws_security_group" "sample_app_sg" {
  name = "sample_app_sg"
  vpc_id = aws_vpc.sample_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "horiken_app_sg"
  }
}

resource "aws_instance" "sample_app" {
  ami = "ami-374db956"
  count = 2
  instance_type = "t3.nano"
  vpc_security_group_ids = [aws_security_group.sample_app_sg.id]
  subnet_id = aws_subnet.sample_public_web.id
  
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "100"
  }

  tags = {
    Name = "horiken_sample_app"
  }
}
