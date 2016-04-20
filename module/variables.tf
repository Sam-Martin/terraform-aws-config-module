
variable "lambda_language_map" {
  type = "map"
  default = {
    "python2.7" = "lambda_handler"
    "nodejs" = "handler"
  }
}


variable "zip_folder" {
  default = "temp/"
}

variable "num_custom_rules" {
  default = 3
}

variable "custom_rules" {
    default = <<EOF
  cloudtrail_enabled_all_regions-periodic,
  iam_mfa_require_root-periodic,
  iam_password_minimum_length-periodic,
  ec2-exposed-instance
EOF
}


variable "custom_rule_languages" {
    default ="nodejs,nodejs,nodejs"
}

variable "custom_rule_input_parameters" {
    default = <<EOF
"","",{
     "MinimumPasswordLength": "8"
  }
EOF
}

variable "custom_rule_message_types" {
  default = <<EOF
ConfigurationSnapshotDeliveryCompleted,
ConfigurationSnapshotDeliveryCompleted,
ConfigurationSnapshotDeliveryCompleted,
ConfigurationItemChangeNotification
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
