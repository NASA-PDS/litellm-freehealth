variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = null
}

variable "venue" {
  description = "Deployment venue (e.g. podaac-sit, pds-test, ...)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group"
  type        = list(string)
}
