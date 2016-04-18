variable "region" {
  default = "us-west-2"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_cloudformation_stack" "awsconfig" {
  name = "aws-config-base"
  template_body = "${file("AWS Config Base.template")}"
  parameters = {
    DeliveryChannelS3Bucket = "bucketofwater"
    DeliveryChannelS3Prefix = "mykeyprefix"
  }
  capabilities = ["CAPABILITY_IAM"]
}

resource "aws_cloudformation_stack" "awsconfgrules" {
  name = "aws-config-config-rules"
  template_body = "${file("AWS Config Rules.template")}"
  parameters = {
    CloudTrailS3Bucket = "test"
  }
  capabilities = ["CAPABILITY_IAM"]
  depends_on = ["aws_cloudformation_stack.awsconfig"]
}

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test_lambda" {
    count = "${var.numcustomrules}"
    filename = "${lookup(var.customrules, count.index)}"
    function_name = "${concat("terraform-generated-rule", count.index)}"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    handler = "exports.test"
    source_code_hash = "${base64sha256(file("${lookup(var.customrules, count.index)}"))}"
}
