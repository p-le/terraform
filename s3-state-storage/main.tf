terraform {
  backend "s3" {
    bucket  = "ple.terraform.state.com"
    key     = "global/tfstate"
    encrypt = "true"
    region  = "ap-northeast-1"
    profile = "devops"
  }
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.terraform_state.arn}"
}

provider "aws" {
  alias   = "tokyo"
  region  = "ap-northeast-1"
  profile = "devops"
}

resource "aws_s3_bucket" "terraform_state" {
  provider = "aws.tokyo"
  bucket   = "ple.terraform.state.com"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
