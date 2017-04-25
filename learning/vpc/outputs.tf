output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "nat_public_ip" {
  value = "${aws_eip.nat.public_ip}"
}
