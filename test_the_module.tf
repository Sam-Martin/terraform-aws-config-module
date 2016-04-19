module "aws_config_rules" {
  source = "module"

  num_custom_rules = 4
  custom_rules = <<EOF
temp/cloudtrail_enabled_all_regions-periodic.zip,
temp/iam_mfa_require_root-periodic.zip,
temp/iam_password_minimum_length-periodic.zip,
temp/ec2-exposed-instance.zip
EOF

  custom_rule_languages = "nodejs,nodejs,nodejs,python2.7"

  custom_rule_input_parameters = <<EOF
{},{},{
       "MinimumPasswordLength": "8"
},{}
EOF

  delivery_channel_s3_bucket_name = "bucketofwater"
  delivery_channel_s3_bucket_prefix = "logs"
}
