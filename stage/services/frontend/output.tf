output "bucket" {
  value = "${aws_s3_bucket.api.id}"
}
output "domain" {
  value = "${aws_s3_bucket.api.website_endpoint}"
}