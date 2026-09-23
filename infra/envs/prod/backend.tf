terraform {
  backend "s3" {
    bucket         = "devops-portfolio-tfstate-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "devops-portfolio-tf-locks-prod"
    encrypt        = true
  }
}
