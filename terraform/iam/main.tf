data "aws_caller_identity" "current" {}

resource "aws_iam_role" "litellm_ecs_task_execution" {
  name = "litellm-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "litellm_ecs_task_execution" {
  role       = aws_iam_role.litellm_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "litellm_secrets" {
  name = "litellm-secrets"
  role = aws_iam_role.litellm_ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = "arn:aws:secretsmanager:us-west-2:${data.aws_caller_identity.current.account_id}:secret:llm-for-dev/litellm/*"
      }
    ]
  })
}

resource "aws_iam_role" "litellm_ecs_task" {
  name = "litellm-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "litellm_ecs_task" {
  name = "litellm-ecs-task-policy"
  role = aws_iam_role.litellm_ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = "arn:aws:secretsmanager:us-west-2:${data.aws_caller_identity.current.account_id}:secret:pds/llm-for-dev/litellm/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:aws:bedrock:us-west-2:${data.aws_caller_identity.current.account_id}:inference-profile/*",
          "arn:aws:bedrock:*::foundation-model/anthropic.claude-sonnet-4-6",
          "arn:aws:bedrock:*::foundation-model/anthropic.claude-sonnet-5"
        ]
      }
    ]
  })
}
