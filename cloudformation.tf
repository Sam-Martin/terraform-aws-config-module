variable "region" {
  default = "us-west-2"
}

provider "aws" {
  region = "${var.region}"
}

resource "template_file" "awsconfigtemplate" {
  template = "${file("AWS Config Base.template")}"
  vars {
    	aws_config_role_arn = "${aws_iam_role.aws_config_role.arn}"
    }
}

resource "aws_cloudformation_stack" "awsconfig" {
  name = "aws-config-base"
  template_body = "${template_file.awsconfigtemplate.rendered}"
  parameters = {
    DeliveryChannelS3Bucket = "${var.delivery_channel_s3_bucket_name}"
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
