variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication (elevated privileges required)"
  type        = string
  default     = null
}

variable "s3_bucket_arn" {
  description = "ARN of the LiteLLM config S3 bucket (output from infra module)"
  type        = string
}
