variable "numcustomrules" {
  default = 2
}

variable "customrules" {
    type = "map"

    default = {
      "0" = "cloudtrail_enabled_all_regions-periodic.zip"
      "1" = "iam_mfa_require_root-periodic.zip"
      "2" = "iam_password_minimum_length-periodic.zip"
    }
}


variable "customrulelanguages" {
    type = "map"

    default = {
      "0" = "js"
      "1" = "js"
      "2" = "js"
    }
}

variable "customruleinputparameters" {
    type = "map"

    default = {
      "0" = ""
      "1" = ""
      "2" = <<EOF
,"InputParameters":
  {
     "MinimumPasswordLength": "8"
  }
EOF
  }
}

variable "delivery_channel_s3_bucket_name" {
  type = "string"
  default = "bucketofwater"
}
