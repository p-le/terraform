provider "aws" {
  alias   = "tokyo"
  region  = "ap-northeast-1"
  profile = "devops"
}

resource "aws_instance" "example" {
  provider               = "aws.tokyo"
  ami                    = "ami-5de0433c"
  instance_type          = "t2.micro"
  availability_zone      = "ap-northeast-1a"
  subnet_id              = "subnet-ec5d1f9a"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  key_name               = "My First Keypair"

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd24 php56 mysql55-server php56-mysqlnd
                service httpd start
                chkconfig httpd on
                groupadd www
                usermod -a -G www ec2-user
                chown -R root:www /var/www
                chmod 2775 /var/www
                find /var/www -type d -exec chmod 2775 {} +
                find /var/www -type f -exec chmod 0664 {} +
                echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
                EOF

  tags {
    Name = "terraform-helloworld"
  }
}

resource "aws_security_group" "instance" {
  provider    = "aws.tokyo"
  name        = "terraform-helloworld-security"
  description = "allow port 80 access for web server"
  vpc_id      = "vpc-88c044ec"

  ingress = {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_80"
  }
}
