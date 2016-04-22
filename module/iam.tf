resource "aws_iam_role" "iam_for_lambda" {
      name = "${var.naming_prefix}-lambda-rules-executor-${var.region}"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_role_policy_for_lambda" {
  name = "ReadLogs"
  role = "${aws_iam_role.iam_for_lambda.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1460390265000",
      "Effect": "Allow",
      "Action": [
        "config:Put*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "config:DeleteDeliveryChannel",
        "config:DescribeConfigurationRecorders",
        "config:DescribeDeliveryChannels",
        "config:PutConfigurationRecorder",
        "config:StopConfigurationRecorder"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject*"
      ],
      "Resource": [
       "arn:aws:s3:::${var.delivery_channel_s3_bucket_name}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "iam_for_lambda" {
  name = "lambda_custom_config_rules_executor"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  roles = ["${aws_iam_role.iam_for_lambda.name}", "${aws_iam_role.aws_config_role.name}"]
}

resource "aws_iam_role" "aws_config_role" {
    name = "${var.naming_prefix}-role-${var.region}"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "config.amazonaws.com"
        ]
      },
      "Action": [
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "aws_config_role" {
  name = "aws_config_role"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
  roles = ["${aws_iam_role.aws_config_role.name}"]
}

resource "aws_iam_role_policy" "aws_config_role" {
  name = "ReadLogs"
  role = "${aws_iam_role.aws_config_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Stmt1460390265000",
        "Effect": "Allow",
        "Action": [
          "config:Put*"
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject*"
        ],
        "Resource": [
         "arn:aws:s3:::${var.delivery_channel_s3_bucket_name}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetBucketAcl"
        ],
        "Resource": "arn:aws:s3:::${var.delivery_channel_s3_bucket_name}"
      },
      {
        "Effect": "Allow",
        "Action": [
            "lambda:InvokeFunction"
        ],
        "Resource": [
            "*"
        ]
      }
    ]
  }
EOF
}
