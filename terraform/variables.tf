variable "aws_region" {
  type        = string
  default     = "us-east-1"
}

variable "project" {
  type        = string
  default     = "hackathon"
}

variable "notification_queue_arn" {
  type        = string
  description = "ARN of the existing SQS queue"
}

variable "mailtrap_user" {
  type        = string
  sensitive   = true
}

variable "mailtrap_pass" {
  type        = string
  sensitive   = true
}

variable "from_email" {
  type        = string
  default     = "no-reply@example.com"
}

variable "user_service_endpoint" {
  type        = string
  default     = "http://localhost:8080/api/v1/users"
}

variable "mailtrap_host" {
  type        = string
  default     = "smtp.mailtrap.io"
}

variable "mailtrap_port" {
  type        = number
  default     = 2525
}
