terraform {
  backend "s3" {
    bucket = "ple.terraform.state"
    key = "stage/vpc/terraform.tfstate"
    region = "ap-northeast-1"
    profile = "devops"
  }
}