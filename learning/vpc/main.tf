provider "aws" {
  region  = "ap-northeast-1"
  profile = "devops"
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "terraform-gw"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.public_subnet_cidr_block}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "terraform-public-subnet"
  }

  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.private_subnet_cidr_block}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "terraform-private-subnet"
  }

  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_security_group" "nat" {
  name        = "vpc_nat"
  vpc_id      = "${aws_vpc.main.id}"
  description = "Allow traffic to pass from the private subnet to the internet"

  # ingress {
  #   from_port  = 80
  #   to_port    = 80
  #   protocol   = "tcp"
  #   cidr_block = "${var.private_subnet_cidr_block}"
  # }


  # ingress {
  #   from_port  = 443
  #   to_port    = 443
  #   protocol   = "tcp"
  #   cidr_block = "${var.private_subnet_cidr_block}"
  # }


  # ingress {
  #   from_port  = 22
  #   to_port    = 22
  #   protocol   = "tcp"
  #   cidr_block = ["0.0.0.0/0"]
  # }

  depends_on = ["aws_subnet.public", "aws_subnet.private"]
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "terraform-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name = "terraform-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_instance" "nat" {
  ami                    = "ami-3b217b5c"
  instance_type          = "t2.micro"
  key_name               = "devops"
  subnet_id              = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
  source_dest_check      = false
  private_ip             = "10.0.0.12"

  tags {
    Name = "terrform-nat-instance"
  }
}

resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc      = true

  associate_with_private_ip = "10.0.0.12"
}
