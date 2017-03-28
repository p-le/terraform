terraform {
  backend "s3" {
    bucket  = "ple.terraform.state.com"
    key     = "stage/data-storage/mysql/terraform.tfstate"
    encrypt = "true"
    region  = "ap-northeast-1"
    profile = "devops"
  }
}

provider "aws" {
  alias   = "tokyo"
  region  = "ap-northeast-1"
  profile = "devops"
}

resource "aws_db_instance" "web_db" {
  provider             = "aws.tokyo"
  availability_zone    = "ap-northeast-1a"
  engine               = "mysql"
  allocated_storage    = 10
  instance_class       = "db.t2.micro"
  identifier           = "mydb"
  name                 = "helloworld"
  username             = "admin"
  password             = "${var.db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.web_db.name}"
}

resource "aws_db_subnet_group" "web_db" {
  provider   = "aws.tokyo"
  name       = "helloworld-db-subnet"
  subnet_ids = ["subnet-ec5d1f9a", "subnet-bf1997e7"]

  tags {
    Name = "My DB subnet group"
  }
}
