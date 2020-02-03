provider "aws" {
  region  = "eu-west-2"
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east"
}

terraform {
  backend "s3" {
    bucket = "720180483130-tfstate"
    key    = "static_s3_site.tfstate"
    region = "eu-west-2"
  }
}
