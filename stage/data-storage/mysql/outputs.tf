output "address" {
  value = "${aws_db_instance.web_db.address}"
}

output "port" {
  value = "${aws_db_instance.web_db.port}"
}
