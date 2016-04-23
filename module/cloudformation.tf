resource "template_file" "aws_config_template" {
  template = "${file("${path.module}/AWS Config Base.template")}"
  vars {
    	aws_config_role_arn = "${aws_iam_role.aws_config_role.arn}"
      delivery_channel_s3_bucket_name = "${var.delivery_channel_s3_bucket_name}"
      delivery_channel_s3_bucket_prefix = "${var.delivery_channel_s3_bucket_prefix}"
    }
  depends_on = ["aws_iam_role.aws_config_role"]
}

resource "aws_cloudformation_stack" "aws_config" {
  name = "${var.naming_prefix}-base"
  template_body = "${template_file.aws_config_template.rendered}"
  capabilities = ["CAPABILITY_IAM"]
}

resource "template_file" "aws_config_rules_template" {
  count = "${var.num_custom_rules}"
  template = "${file("${path.module}/AWS Custom Config Rules.template")}"
  vars {
      config_rule_name = "${replace(element(split(\",\",var.custom_rules), count.index),"/(^[^a-zA-Z]{1,1}|[^-a-zA-Z0-9_]+)/","")}"
    	parameters = "${element(split(\";\",var.custom_rule_input_parameters),count.index)}"
      lambda_arn = "${element(aws_lambda_function.config_rules_lambda.*.arn, count.index)}"
      message_type = "${element(replace(split(\";\",var.custom_rule_message_types), "/[\\r\\n]+/",""),count.index)}"
      scope = "${element(split(\";\",var.custom_rule_scope),count.index)}"
    }
}

resource "aws_cloudformation_stack" "aws_config_rules" {
  count = "${var.num_custom_rules}"
  name = "${var.naming_prefix}-rule-${replace(element(split(\",\",var.custom_rules), count.index),"/(^[^a-zA-Z]+|[^-a-zA-Z0-9]+)/","")}"
  template_body = "${element(template_file.aws_config_rules_template.*.rendered, count.index)}"
  depends_on = ["aws_cloudformation_stack.aws_config", "template_file.aws_config_rules_template"]
}
