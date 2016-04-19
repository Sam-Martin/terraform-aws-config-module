module "aws_config_rules" {
  source = "module"
  custom_rules = "temp/cloudtrail_enabled_all_regions-periodic.zip,temp/iam_mfa_require_root-periodic.zip,temp/iam_password_minimum_length-periodic.zip"
  custom_rule_languages = "js,js,js"

  custom_rule_input_parameters = <<EOF
,,{
   "MinimumPasswordLength": "8"
}
EOF

  delivery_channel_s3_bucket_name = "bucketofwater"
  delivery_channel_s3_bucket_prefix = "logs"
}
