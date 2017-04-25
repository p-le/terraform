terraform {
  backend "s3" {
    bucket = "ple.terraform.state"
    key = "stage/service/frontend/terraform.tfstate"
    region = "ap-northeast-1"
    profile = "devops"
  }
}