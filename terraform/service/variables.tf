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
  description = "Deployment venue (e.g. podaac-dev)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the ECS service"
  type        = list(string)
}

variable "alb_subnet_ids" {
  description = "Subnet IDs for the ALB; defaults to subnet_ids if not set"
  type        = list(string)
  default     = null
}

variable "alb_internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false)"
  type        = bool
  default     = true
}

variable "jplnet_cidr_blocks" {
  description = "CIDR blocks for JPL network inbound access to the ALB on port 80"
  type        = list(string)
  default     = ["128.149.0.0/16"]
}

variable "task_cpu" {
  description = "CPU units for the ECS Fargate task (1024 = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Memory in MiB for the ECS Fargate task"
  type        = number
  default     = 2048
}

variable "desired_count" {
  description = "Desired number of running ECS task instances"
  type        = number
  default     = 1
}

variable "project" {
  description = "Project identifier used as a prefix in Secrets Manager paths and other shared resources"
  type        = string
  default     = "pds"
}

variable "db_secret_arn" {
  description = "ARN of the RDS-managed secret (rds_master_user_secret_arn output from the infra module), passed to the container as DB_SECRET_ARN"
  type        = string
}

variable "task_execution_role_name" {
  description = "Name of the ECS task execution IAM role (created in iam module)"
  type        = string
  default     = "am-litellm-ecs-task-execution"
}

variable "task_role_name" {
  description = "Name of the ECS task IAM role (created in iam module)"
  type        = string
  default     = "am-litellm-ecs-task-role"
}
