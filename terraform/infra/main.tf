resource "aws_s3_bucket" "litellm_config" {
  bucket = "${var.venue}-litellm-for-teams"
}

resource "aws_s3_bucket_versioning" "litellm_config" {
  bucket = aws_s3_bucket.litellm_config.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "litellm_config" {
  bucket = aws_s3_bucket.litellm_config.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "litellm_config" {
  bucket = aws_s3_bucket.litellm_config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "litellm_config" {
  bucket = aws_s3_bucket.litellm_config.id
  key    = "config.yaml"
  source = "${path.module}/config.yaml"
  etag   = filemd5("${path.module}/config.yaml")
}

resource "aws_security_group" "litellm_rds" {
  name        = "${var.venue}-litellm-rds"
  description = "Allow PostgreSQL access to LiteLLM Aurora cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "litellm" {
  name       = "${var.venue}-litellm"
  subnet_ids = var.subnet_ids
}

resource "aws_rds_cluster" "litellm" {
  cluster_identifier              = "${var.venue}-litellm"
  engine                          = "aurora-postgresql"
  engine_version                  = "17"
  database_name                   = "litellm"
  master_username                 = "litellm"
  manage_master_user_password     = true
  db_subnet_group_name            = aws_db_subnet_group.litellm.name
  vpc_security_group_ids          = [aws_security_group.litellm_rds.id]
  db_cluster_parameter_group_name = "default.aurora-postgresql17"
  skip_final_snapshot             = true
}

resource "aws_rds_cluster_instance" "litellm" {
  identifier           = "${var.venue}-litellm"
  cluster_identifier   = aws_rds_cluster.litellm.id
  instance_class       = "db.t4g.medium"
  engine               = aws_rds_cluster.litellm.engine
  engine_version       = aws_rds_cluster.litellm.engine_version
  db_subnet_group_name = aws_db_subnet_group.litellm.name
}
