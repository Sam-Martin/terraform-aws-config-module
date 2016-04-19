variable "region" {
  default = "us-west-2"
}

provider "aws" {
  region = "${var.region}"
}

resource "template_file" "aws_config_template" {
  template = "${file("${path.module}/AWS Config Base.template")}"
  vars {
    	aws_config_role_arn = "${aws_iam_role.aws_config_role.arn}"
      delivery_channel_s3_bucket_name = "${var.delivery_channel_s3_bucket_name}"
      delivery_channel_s3_bucket_prefix = "${var.delivery_channel_s3_bucket_prefix}"
    }
}

resource "aws_cloudformation_stack" "aws_config" {
  name = "aws-config-base"
  template_body = "${template_file.aws_config_template.rendered}"
  capabilities = ["CAPABILITY_IAM"]
}

resource "template_file" "aws_config_rules_template" {
  count = "${var.num_custom_rules}"
  template = "${file("${path.module}/AWS Config Rules.template")}"
  vars {
    	parameters = "${element(split(\",\",var.custom_rule_input_parameters),count.index)}"
      lambda_arn = "${element(aws_lambda_function.config_rules_lambda.*.arn, count.index)}"
    }
}


resource "aws_cloudformation_stack" "aws_config_rules" {
  count = "${var.num_custom_rules}"
  name = "aws-config-custom-rule-${replace(element(split(\",\",var.custom_rules), count.index),"/([^a-zA-Z][^-a-zA-Z0-9]*|\\.\\w*$|.*\\/)/","")}"
  template_body = "${element(template_file.aws_config_rules_template.*.rendered, count.index)}"
  depends_on = ["aws_cloudformation_stack.aws_config", "template_file.aws_config_rules_template"]
}
