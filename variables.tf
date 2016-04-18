variable "numcustomrules" {
  default = 2
}
variable "customrules" {
    type = "map"

    default = {
      "0" = "cloudtrail_enabled_all_regions-periodic.zip"
      "1" = "iam_mfa_require_root-periodic.zip"
    }
}


variable "customrulelanguages" {
    type = "map"

    default = {
      "0" = "js"
      "1" = "js"
    }
}
