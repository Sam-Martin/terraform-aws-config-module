resource "aws_sns_topic" "aws_config" {
  name = "${var.naming_prefix}-topic"
}
