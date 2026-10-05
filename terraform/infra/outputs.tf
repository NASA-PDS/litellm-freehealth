output "s3_bucket_arn" {
  value = aws_s3_bucket.litellm_config.arn
}

output "rds_master_user_secret_arn" {
  description = "ARN of the RDS-managed secret containing Aurora master user credentials — look it up in Secrets Manager if you need the connection details"
  value       = aws_rds_cluster.litellm.master_user_secret[0].secret_arn
}
