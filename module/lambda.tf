resource "aws_lambda_function" "config_rules_lambda" {
    count = "${var.num_custom_rules}"
    filename = "${element(split(\",\",var.custom_rules), count.index)}"
    function_name = "${replace(element(split(\",\",var.custom_rules), count.index),"/(\\.\\w*$|.*\\/)/","")}"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    handler = "exports.test"
    source_code_hash = "${base64sha256(file("${element(split(\",\",var.custom_rules), count.index)}"))}"
}

resource "aws_lambda_permission" "allow_aws_config" {
    count = "${var.num_custom_rules}"
    statement_id = "AllowExecutionFromAWSConfig"
    action = "lambda:InvokeFunction"
    function_name = "${replace(element(split(\",\",var.custom_rules), count.index),"/(\\.\\w*$|.*\\/)/","")}"
    principal = "config.amazonaws.com"
    depends_on = [ "aws_lambda_function.config_rules_lambda"]
}
