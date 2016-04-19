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

resource "template_file" "awsconfgrulestemplate" {
  count = "${var.numcustomrules}"
  template = "${file("AWS Config Rules.template")}"
    vars {
    	parameters = "${lookup(var.customruleinputparameters,count.index)}"
      lambda_arn = "${element(aws_lambda_function.configruleslambda.*.arn, count.index)}"
    }
}


resource "aws_cloudformation_stack" "awsconfgrules" {
  count = "${var.numcustomrules}"
  name = "${replace(lookup(var.customrules, count.index),"/[^a-zA-Z][^-a-zA-Z0-9]*/","")}"
  template_body = "${element(template_file.awsconfgrulestemplate.*.rendered, count.index)}"
  depends_on = ["aws_cloudformation_stack.awsconfig", "template_file.awsconfgrulestemplate"]
}
