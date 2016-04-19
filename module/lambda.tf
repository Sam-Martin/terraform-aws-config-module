resource "aws_lambda_function" "config_rules_lambda" {
    count = "${var.num_custom_rules}"
    filename = "${var.zip_folder}${element(replace(split(\",\",var.custom_rules), "/[\\r\\n]+/",""), count.index)}.zip"
    function_name = "aws-config-rule-${replace(element(split(\",\",var.custom_rules), count.index),"/[^a-zA-Z][^-a-zA-Z0-9]*/","")}"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    handler = "${element(replace(split(\",\",var.custom_rules), "/[\\r\\n]+/",""), count.index)}.${lookup(var.lambda_language_map,element(split(\",\",var.custom_rule_languages), count.index))}"
    runtime = "${element(split(\",\",var.custom_rule_languages), count.index)}"
    source_code_hash = "${base64sha256(file("${var.zip_folder}${element(replace(split(\",\",var.custom_rules), "/[\\r\\n]+/",""), count.index)}.zip"))}"
}

resource "aws_lambda_permission" "allow_aws_config" {
    count = "${var.num_custom_rules}"
    statement_id = "AllowExecutionFromAWSConfig"
    action = "lambda:InvokeFunction"
    function_name = "${element(aws_lambda_function.config_rules_lambda.*.function_name, count.index)}"
    principal = "config.amazonaws.com"
    depends_on = [ "aws_lambda_function.config_rules_lambda"]
}
