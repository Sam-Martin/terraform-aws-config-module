# aws-config-custom-rules-terraform
This Terraform module allows you to automatically setup custom AWS Config rules.  
This module uses CloudFormation and Lambda in the back end to control the AWS Config components, due to a lack of support for AWS Config in Terraform at the time of writing.  

# Requirements  
* Custom rule's runtime function must be `lambda_handler` for Python scripts and `handler` for NodeJS scripts

# Setup
1. Create a bucket in which to place your config snapshots.
1. Download and package your rules as .py or .js files named after the rules into zip files named identically bar the file extension (use the `package-rule-lambda-functions.ps1` if on Windows)  
2. Place the zip files in `temp/` within the repository directory (or modify the `zip_folder` parameter to specify another path)  
3. Run the module as per the example in usage  

# Variables  

* `region` AWS region, does not set AWS region. Used to name roles etc. (**required**)  
* `delivery_channel_s3_bucket_name` name of the bucket in which you wish to store your config snapshots (**required**)  
* `delivery_channel_s3_bucket_prefix` key prefix to be used inside the bucket (defaults to blank)   
* `num_custom_rules` used to enumerate the custom rules (**required**)  
* `custom_rules` semicolon separated list of custom rule zip file names (**required**)  
* `custom_rule_languages` semicolon separated list of custom rule languages (affects runtime function) (**required**)
* `custom_rule_input_parameters` semicolon separated list of rules' parameters (use `{}` for no parameters) (**required**)  
* `custom_rule_message_types` semicolon separated list of trigger type for each custom rule. Valid values: `ConfigurationSnapshotDeliveryCompleted` and `ConfigurationItemChangeNotification` (**required**)  
* `custom_rule_scope` semicolon separated list of rule scopes (see [AWS Config ConfigRule Scope](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-config-configrule-scope.html)) (**required**)
* `zip_folder` relative or absolute path to the zips of the custom rule's lambda functions (defaults to `temp/`)  


# Example Usage

```
variable "region" {
  type = "string"
  default = "eu-west-1"
}

provider "aws" {
  region = "${var.region}"
}

module "aws_config_rules" {
  source = "github.com/Sam-Martin/terraform-aws-config-module/module"
  zip_folder = "${var.zip_folder}"
  region = "${var.region}"
  naming_prefix = "awsconfig"

  num_custom_rules = 4
  custom_rules = <<EOF
cloudtrail_enabled_all_regions-periodic;
iam_mfa_require_root-periodic;
iam_password_minimum_length-periodic;
ec2-exposed-instance
EOF

  custom_rule_languages = "nodejs;nodejs;nodejs;python2.7"

  custom_rule_input_parameters = <<EOF
{};{};{
       "MinimumPasswordLength": "8"
};{
    "RDP": "3389",
    "SSH": "22"
  }
EOF

  delivery_channel_s3_bucket_name = "awsconfigtestbucket"
  delivery_channel_s3_bucket_prefix = "logs"

  custom_rule_message_types = <<EOF
ConfigurationSnapshotDeliveryCompleted;
ConfigurationSnapshotDeliveryCompleted;
ConfigurationSnapshotDeliveryCompleted;
ConfigurationItemChangeNotification
EOF

  custom_rule_scope = <<EOF
{};{};{};
{
"ComplianceResourceTypes": [
    "AWS::EC2::Instance"
  ]
}
EOF
}

```
