module "aws_config_rules" {
  source = "module"

  num_custom_rules = 4
  custom_rules = <<EOF
cloudtrail_enabled_all_regions-periodic,
iam_mfa_require_root-periodic,
iam_password_minimum_length-periodic,
ec2-exposed-instance
EOF

  custom_rule_languages = "nodejs,nodejs,nodejs,python2.7"

  custom_rule_input_parameters = <<EOF
{},{},{
       "MinimumPasswordLength": "8"
},{}
EOF

  delivery_channel_s3_bucket_name = "awsconfigtestbucket"
  delivery_channel_s3_bucket_prefix = "logs"
}
