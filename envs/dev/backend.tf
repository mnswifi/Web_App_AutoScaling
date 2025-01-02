terraform {
  backend "s3" {
    bucket         = "tf-challenge-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-challenge-state-lock"
  }
}