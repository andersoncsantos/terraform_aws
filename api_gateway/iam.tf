data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "hello_lambda_role" {
  name               = "hello_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}
