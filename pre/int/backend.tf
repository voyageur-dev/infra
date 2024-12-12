terraform {
  backend "s3" {
    bucket = "pre-voyageur-tfstate"
    key     = "int/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
