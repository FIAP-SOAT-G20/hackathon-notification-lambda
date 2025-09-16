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
  description = "ARN da fila SQS já existente"
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

variable "subject_prefix" {
  type        = string
  default     = "[Video Service] "
}

variable "mailtrap_host" {
  type        = string
  default     = "smtp.mailtrap.io"
}

variable "mailtrap_port" {
  type        = number
  default     = 587
}
