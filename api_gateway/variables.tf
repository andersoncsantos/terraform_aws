variable "region" {
  default = "us-east-1"
}

variable "shared_credentials_file" {
  default = "/home/anderson/.aws/credentials"
}

variable "profile" {
  default     = "terraform-test"
  description = "aws account user profile"
}
