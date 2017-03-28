output "public_ip" {
  value = "${aws_elb.helloworld.dns_name}"
}
