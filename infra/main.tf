#terraform block 
terraform {
  required_providers {
    aws = {
      version = ">= 4.0.0"
      source  = "hashicorp/aws"
    }
  }
}

# specify the provider region
provider "aws" {
  region = "ca-central-1"
}

# the locals block is used to declare constants that 
# you can use throughout your code - variables youre able to use throughout config
locals {
  function_name           = "save-note"
  save_note_handler_name  = "main.save_lambda_handler_30144844"
  save_note_artifact_name = "save-note-artifact.zip"
}

locals {
  function_name2            = "delete-note"
  delete_note_handler_name  = "main.delete_lambda_handler_30087175"
  delete_note_artifact_name = "delete-note-artifact.zip"
}

locals {
  function_name3         = "get-note"
  get_note_handler_name  = "main.get_lambda_handler_30144844"
  get_note_artifact_name = "get-note-artifact.zip"
}

# create a role for the Lambda function to assume
# every service on AWS that wants to call other AWS services should first assume a role and
# then any policy attached to the role will give permissions
# to the service so it can interact with other AWS services
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "save_note_lambda" {
  name               = "iam-for-lambda-${local.function_name}"
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

#create a role for the delete-note Lambda function to assume
resource "aws_iam_role" "delete_note_lambda" {
  name               = "iam-for-lambda-${local.function_name2}"
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

#create a role for the get-note Lambda function to assume
resource "aws_iam_role" "get_note_lambda" {
  name               = "iam-for-lambda-${local.function_name3}"
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




# create archive file from main.py
data "archive_file" "save_note_lambda" {
  type = "zip"
  # this file (main.py) needs to exist in the same folder as this 
  # Terraform configuration file
  source_file = "../functions/save-note/main.py"
  output_path = "save-note-artifact.zip" #deployment package
}

# create archive file from main.py for delete-note
data "archive_file" "delete_note_lambda" {
  type        = "zip"
  source_file = "../functions/delete-note/main.py"
  output_path = "delete-note-artifact.zip"
}

# create archive file from main.py for get-note
data "archive_file" "get_note_lambda" {
  type        = "zip"
  source_file = "../functions/get-notes/main.py"
  output_path = "get-note-artifact.zip"

}

# create a Lambda function
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "save_note_lambda" {
  role             = aws_iam_role.save_note_lambda.arn
  function_name    = local.function_name
  handler          = local.save_note_handler_name
  filename         = local.save_note_artifact_name
  source_code_hash = data.archive_file.save_note_lambda.output_base64sha256

  # see all available runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "python3.9"
}


# create a Lambda function delete-note
resource "aws_lambda_function" "delete_note_lambda" {
  role             = aws_iam_role.delete_note_lambda.arn
  function_name    = local.function_name2
  handler          = local.delete_note_handler_name
  filename         = local.delete_note_artifact_name
  source_code_hash = data.archive_file.delete_note_lambda.output_base64sha256

  runtime = "python3.9"
}


# create a Lambda function get-note
resource "aws_lambda_function" "get_note_lambda" {
  role             = aws_iam_role.get_note_lambda.arn
  function_name    = local.function_name3
  handler          = local.get_note_handler_name
  filename         = local.get_note_artifact_name
  source_code_hash = data.archive_file.get_note_lambda.output_base64sha256

  runtime = "python3.9"

}


# create a policy for publishing logs to CloudWatch
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "logs_save" {
  name        = "lambda-logging-${local.function_name}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:PutItem"
      ],
      "Resource": ["arn:aws:logs:*:*:*", "${aws_dynamodb_table.notes.arn}"],
      "Effect": "Allow"
    }
  ]
}
EOF
}

# create a policy for publishing logs to CloudWatch for delete-note
resource "aws_iam_policy" "logs_delete" {
  name        = "lambda-logging-${local.function_name2}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:DeleteItem"
      ],
      "Resource": ["arn:aws:logs:*:*:*", "${aws_dynamodb_table.notes.arn}"],
      "Effect": "Allow"
    }
  ]
}
EOF
}

# create a policy for publishing logs to CloudWatch for delete-note
resource "aws_iam_policy" "logs_get" {
  name        = "lambda-logging-${local.function_name3}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:Query"
        

      ],
      "Resource": ["arn:aws:logs:*:*:*", "${aws_dynamodb_table.notes.arn}"],
      "Effect": "Allow"
    }
  ]
}
EOF
}


# attach the above policy to the function role
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "lambda_logs_save" {
  role       = aws_iam_role.save_note_lambda.name
  policy_arn = aws_iam_policy.logs_save.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs_delete" {
  role       = aws_iam_role.delete_note_lambda.name
  policy_arn = aws_iam_policy.logs_delete.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs_get" {
  role       = aws_iam_role.get_note_lambda.name
  policy_arn = aws_iam_policy.logs_get.arn
}


# create a Function URL for Lambda 
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url
resource "aws_lambda_function_url" "url_save" {
  function_name      = aws_lambda_function.save_note_lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

resource "aws_lambda_function_url" "url_delete" {
  function_name      = aws_lambda_function.delete_note_lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["DELETE"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}


resource "aws_lambda_function_url" "url_get" {
  function_name      = aws_lambda_function.get_note_lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}


# show the Function URL after creation
output "save_note_lambda_url" {
  value = aws_lambda_function_url.url_save.function_url
}


# show the Function URL for delete-note after creation
output "delete_note_lambda_url" {
  value = aws_lambda_function_url.url_delete.function_url
}


# show the Function URL for get-note after creation
output "get_note_lambda_url" {
  value = aws_lambda_function_url.url_get.function_url
}

# read the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "notes" {
  name         = "notes-30144844"
  billing_mode = "PROVISIONED"

  # up to 8KB read per second (eventually consistent)
  read_capacity = 1

  # up to 1KB per second
  write_capacity = 1

  # we only need a student id to find an item in the table; therefore, we 
  # don't need a sort key here
  hash_key  = "email"
  range_key = "id"

  # the hash_key data type is string
  attribute {
    name = "email"
    type = "S"
  }
  # the hash_key data type is string
  attribute {
    name = "id"
    type = "S"
  }
}

# S3 bucket
# if you omit the name, Terraform will assign a random name to it
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "lambda" {
  bucket = "lotion-plus-rimal-afrah"
}

# output the name of the bucket after creation
output "bucket_name" {
  value = aws_s3_bucket.lambda.bucket
}
