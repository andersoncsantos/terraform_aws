provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/home/anderson/.aws/credentials"
  profile                 = "terraform-test"
}

resource "aws_s3_bucket" "b" {
  bucket = "pre-signed-bucket-teste-002"
  acl    = "private"

  tags = {
    Name        = ""
    Environment = ""
  }
}
