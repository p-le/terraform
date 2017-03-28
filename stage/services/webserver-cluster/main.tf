provider "aws" {
  alias   = "tokyo"
  region  = "ap-northeast-1"
  profile = "devops"
}

# resource "aws_instance" "helloworld" {
#   provider               = "aws.tokyo"
#   ami                    = "ami-5de0433c"
#   instance_type          = "t2.micro"
#   availability_zone      = "ap-northeast-1a"
#   subnet_id              = "subnet-ec5d1f9a"
#   vpc_security_group_ids = ["${aws_security_group.instance.id}"]
#   key_name               = "My First Keypair"

#   user_data = <<-EOF
#                 #!/bin/bash
#                 yum update -y
#                 yum install -y httpd24 php56 mysql55-server php56-mysqlnd
#                 service httpd start
#                 chkconfig httpd on
#                 groupadd www
#                 usermod -a -G www ec2-user
#                 chown -R root:www /var/www
#                 chmod 2775 /var/www
#                 find /var/www -type d -exec chmod 2775 {} +
#                 find /var/www -type f -exec chmod 0664 {} +
#                 echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
#                 EOF

#   tags {
#     Name = "terraform-helloworld"
#   }
# }

resource "aws_security_group" "instance" {
  provider    = "aws.tokyo"
  name        = "terraform-helloworld-security"
  description = "allow port 80 access for web server"
  vpc_id      = "vpc-88c044ec"

  ingress = {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "allow_80"
  }
}

resource "aws_security_group" "elb" {
  provider = "aws.tokyo"
  name     = "terraform-helloworld-elb-sg"
  vpc_id   = "vpc-88c044ec"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "helloworld" {
  provider        = "aws.tokyo"
  name            = "web_cluster"
  image_id        = "ami-5de0433c"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = "${file("user-data.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "helloworld" {
  provider = "aws.tokyo"
  name     = "terraform-test"

  vpc_zone_identifier  = ["subnet-ec5d1f9a", "subnet-bf1997e7"]
  launch_configuration = "${aws_launch_configuration.helloworld.id}"

  load_balancers    = ["${aws_elb.helloworld.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-test"
    propagate_at_launch = true
  }
}

resource "aws_elb" "helloworld" {
  provider        = "aws.tokyo"
  name            = "web-terraform-elb"
  subnets         = ["subnet-ec5d1f9a", "subnet-bf1997e7"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}
