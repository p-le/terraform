provider "aws" {
  alias   = "tokyo"
  region  = "ap-northeast-1"
  profile = "devops"
}

resource "aws_instance" "example" {
  provider          = "aws.tokyo"
  ami               = "ami-5de0433c"
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-1a"
  subnet_id         = "subnet-ec5d1f9a"

  tags {
    Name = "terraform-helloworld"
  }
}
