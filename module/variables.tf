variable "numcustomrules" {
  default = 2
}

variable "customrules" {
    default = "cloudtrail_enabled_all_regions-periodic.zip,iam_mfa_require_root-periodic.zip,iam_password_minimum_length-periodic.zip"
}


variable "customrulelanguages" {
    default ="js,js,js"
}

variable "customruleinputparameters" {
    default = <<EOF
,,{
     "MinimumPasswordLength": "8"
  }
EOF
}

variable "delivery_channel_s3_bucket_name" {
  type = "string"
  default = "bucketofwater"
}

variable "delivery_channel_s3_bucket_prefix" {
  type = "string"
  default = "mylogs"
  description = "The prefix to prepend to the key of all logs in the delivery channel's s3 bucket (no leading or trailing slashes required)"
}
