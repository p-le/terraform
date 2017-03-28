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
  provider          = "aws.tokyo"
  engine            = "mysql"
  allocated_storage = 10
  engine_version    = "5.6.17"
  instance_class    = "db.t2.micro"
  name              = "mydb"
  username          = "admin"
  password          = "${var.db_password}"
}
