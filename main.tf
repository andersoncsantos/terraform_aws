module "api_gateway" {
  source = "./api_gateway"
}

module "ec2" {
  source = "./EC2"
}

module "lambda_function" {
  source = "./lambda_function"
}

module "s3" {
  source = "./S3"
}

module "vpc" {
  source = "./VPC"
}
