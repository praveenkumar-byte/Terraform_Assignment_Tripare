terraform {
  backend "s3" {
    bucket         = "devops-portfolio-tfstate-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "devops-portfolio-tf-locks-dev"
    encrypt        = true
  }
}
