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
