module "my_web_elb" {
  source = "module"
  customrules = "temp/cloudtrail_enabled_all_regions-periodic.zip,temp/iam_mfa_require_root-periodic.zip,temp/iam_password_minimum_length-periodic.zip"
  customrulelanguages = "js,js,js"

  customruleinputparameters = <<EOF
,,{
   "MinimumPasswordLength": "8"
}
EOF

  delivery_channel_s3_bucket_name = "bucketofwater"
  delivery_channel_s3_bucket_prefix = "logs"
}
