data "terraform_remote_state" "main" {
  backend = "s3"

  config {
    bucket = "ple.terraform.state"
    key    = "stage/services/frontend/terraform.state"
    region = "ap-northeast-1"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
