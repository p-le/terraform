provider "aws" {
  region = "ap-northeast-1"
  profile = "devops"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "terraform-api-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "terraform-api-gw"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnet_cidr_block}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "terraform-api-public-subnet"
  }

  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_security_group" "api_sg" {
  name        = "api_sg"
  vpc_id      = "${aws_vpc.main.id}"
  description = "Accept SSH to backend Instance from anyone"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = ["aws_subnet.public"]
  tags {
    Name = "terraform-api-sg"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "terraform-api-public-rt"
  }
}

resource "aws_instance" "backend" {
  ami = "ami-5de0433c"
  instance_type = "t2.micro"
  key_name = "devops"
  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.api_sg.id}"]
  associate_public_ip_address = true
  
  tags {
    Name = "terraform-api-instance"
  }
}

resource "aws_vpc_endpoint" "frontend_s3" {
  vpc_id = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.ap-northeast-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "frontend-s3" {
  vpc_endpoint_id = "${aws_vpc_endpoint.frontend_s3.id}"
  route_table_id = "${aws_route_table.public.id}"
}