terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_iam_role" "fiap_lab_role" {
  name = "LabRole"
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
  name   = "${var.project}-lambda-sqs-policy-v6"
  policy = data.aws_iam_policy_document.lambda_sqs_policy_doc.json
}


resource "aws_lambda_function" "notification" {
  function_name = "${var.project}-notification-lambda-v6"
  role          = data.aws_iam_role.fiap_lab_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/lambda-deployment-package.zip"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      MAILTRAP_USER         = var.mailtrap_user
      MAILTRAP_PASS         = var.mailtrap_pass
      FROM_EMAIL            = var.from_email
      USER_SERVICE_ENDPOINT = var.user_service_endpoint
      MAILTRAP_HOST         = var.mailtrap_host
      MAILTRAP_PORT         = tostring(var.mailtrap_port)
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.notification.function_name}"
  retention_in_days = 14
}

# Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = var.notification_queue_arn
  function_name    = aws_lambda_function.notification.arn
  batch_size       = 5
  enabled          = true
}
