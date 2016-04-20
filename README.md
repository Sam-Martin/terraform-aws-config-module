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
