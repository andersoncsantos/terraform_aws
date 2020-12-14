provider "aws" {
  region                  = var.region
  shared_credentials_file = var.shared_credentials_file
  profile                 = var.profile
}

resource "aws_s3_bucket" "b" {
  bucket = "pre-signed-bucket-teste-002"
  acl    = "private"

  tags = {
    Name        = ""
    Environment = ""
  }
}
