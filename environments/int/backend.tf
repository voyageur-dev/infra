terraform {
  backend "s3" {
    bucket = "voyageur-tfstate"
    key     = "${var.environment}/terraform.tfstate"
    region  = var.region
    encrypt = true
  }
}
