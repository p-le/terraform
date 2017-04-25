terraform {
  backend "s3" {
    bucket  = "ple.terraform.state"
    key     = "learning/vpc/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "devops"
  }
}
