provider "aws" {
  region = "ap-northeast-1"
  profile = "devops"
}

resource "aws_s3_bucket" "log" {
  bucket = "log.p2.api.com"
  acl = "log-delivery-write"
}
resource "aws_s3_bucket" "api" {
  bucket = "p2.api.com"
  acl = "public-read"
  policy = "${file("policy.json")}"
  
  website {
    index_document = "index.html"
  }

  logging {
    target_bucket = "${aws_s3_bucket.log.id}"
    target_prefix = "api/"
  }
}