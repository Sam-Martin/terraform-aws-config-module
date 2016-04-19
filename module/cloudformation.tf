variable "region" {
  default = "us-west-2"
}

provider "aws" {
  region = "${var.region}"
}

resource "template_file" "awsconfigtemplate" {
  template = "${file("${path.module}/AWS Config Base.template")}"
  vars {
    	aws_config_role_arn = "${aws_iam_role.aws_config_role.arn}"
      delivery_channel_s3_bucket_name = "${var.delivery_channel_s3_bucket_name}"
      delivery_channel_s3_bucket_prefix = "${var.delivery_channel_s3_bucket_prefix}"
    }
}

resource "aws_cloudformation_stack" "awsconfig" {
  name = "aws-config-base"
  template_body = "${template_file.awsconfigtemplate.rendered}"
  capabilities = ["CAPABILITY_IAM"]
}

resource "template_file" "awsconfgrulestemplate" {
  count = "${var.numcustomrules}"
  template = "${file("${path.module}/AWS Config Rules.template")}"
  vars {
    	parameters = "${element(split(\",\",var.customruleinputparameters),count.index)}"
      lambda_arn = "${element(aws_lambda_function.configruleslambda.*.arn, count.index)}"
    }
}


resource "aws_cloudformation_stack" "awsconfgrules" {
  count = "${var.numcustomrules}"
  name = "${replace(element(split(\",\",var.customrules), count.index),"/([^a-zA-Z][^-a-zA-Z0-9]*|\\.\\w*$|.*\\/)/","")}"
  template_body = "${element(template_file.awsconfgrulestemplate.*.rendered, count.index)}"
  depends_on = ["aws_cloudformation_stack.awsconfig", "template_file.awsconfgrulestemplate"]
}
