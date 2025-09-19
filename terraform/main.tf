terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# IAM Role
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.project}-notification-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permissão para consumir SQS existente
data "aws_iam_policy_document" "lambda_sqs_policy_doc" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility"
    ]
    resources = [var.notification_queue_arn]
  }
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name   = "${var.project}-lambda-sqs-policy"
  policy = data.aws_iam_policy_document.lambda_sqs_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

# Empacotar código
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/build/notification_lambda.zip"
}

# Lambda
resource "aws_lambda_function" "notification" {
  function_name = "${var.project}-notification-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 30
  memory_size   = 256
  environment {
    variables = {
      MAILTRAP_USER  = var.mailtrap_user
      MAILTRAP_PASS  = var.mailtrap_pass
      FROM_EMAIL     = var.from_email
      USER_SERVICE_ENDPOINT = var.user_service_endpoint
      MAILTRAP_HOST  = var.mailtrap_host
      MAILTRAP_PORT  = tostring(var.mailtrap_port)
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.notification.function_name}"
  retention_in_days = 14
}

# Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn                   = var.notification_queue_arn
  function_name                      = aws_lambda_function.notification.arn
  batch_size                         = 5
  maximum_batching_window_in_seconds = 2
  enabled                            = true
}
