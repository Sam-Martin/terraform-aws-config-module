# aws-config-custom-rules-terraform
This Terraform module allows you to automatically setup custom AWS Config rules.  
This module uses CloudFormation and Lambda in the back end to control the AWS Config components, due to a lack of support for AWS Config in Terraform at the time of writing.  

# Requirements  
* The bucket which stores AWS Config Snapshots must be in "US Standard" region
* Custom rule's runtime function must be `lambda_handler` for Python scripts and `handler` for NodeJS scripts

# Setup
1. Create a bucket in the `us-standard` region in which to place your config snapshots.
1. Download and package your rules as .py or .js files named after the rules into zip files named identically bar the file extension (use the `package-rule-lambda-functions.ps1` if on Windows)  
2. Place the zip files in `temp/` within the repository directory (or modify the `zip_folder` parameter to specify another path)  
3. Run the module as per the example in usage  

# Usage

```
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
ConfigurationSnapshotDeliveryCompleted,
ConfigurationSnapshotDeliveryCompleted,
ConfigurationSnapshotDeliveryCompleted,
ConfigurationItemChangeNotification
EOF

  custom_rule_scope = <<EOF
{};{};{};
{
"ComplianceResourceTypes": [
    "AWS::EC2::SecurityGroup"
  ]
}
EOF
}

```
