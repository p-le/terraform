output "instance_dns" {
  value = "${aws_instance.backend.public_dns}"
}
output "instance_ip" {
  value = "${aws_instance.backend.public_ip}"
}