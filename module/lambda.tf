resource "aws_lambda_function" "config_rules_lambda" {
    count = "${var.num_custom_rules}"
    filename = "${element(replace(split(\",\",var.custom_rules), "/[\\r\\n]+/",""), count.index)}"
    function_name = "aws-config-rule-${replace(element(split(\",\",var.custom_rules), count.index),"/(\\.zip|.*\\/|\\W+)/","")}"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    handler = "exports.test"
    runtime = "${element(split(\",\",var.custom_rule_languages), count.index)}"
    source_code_hash = "${base64sha256(file("${element(replace(split(\",\",var.custom_rules), "/[\\r\\n]+/",""), count.index)}"))}"
}

resource "aws_lambda_permission" "allow_aws_config" {
    count = "${var.num_custom_rules}"
    statement_id = "AllowExecutionFromAWSConfig"
    action = "lambda:InvokeFunction"
    function_name = "${element(aws_lambda_function.config_rules_lambda.*.function_name, count.index)}"
    principal = "config.amazonaws.com"
    depends_on = [ "aws_lambda_function.config_rules_lambda"]
}
