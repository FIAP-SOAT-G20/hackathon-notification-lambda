output "notification_lambda_name" {
  value = aws_lambda_function.notification.function_name
}

output "notification_lambda_arn" {
  value = aws_lambda_function.notification.arn
}

