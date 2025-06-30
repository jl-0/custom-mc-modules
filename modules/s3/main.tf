# Unity S3 Bucket Module
# Creates an S3 bucket with Unity best practices and security configurations

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Local values for consistent naming and tagging
locals {
  tags = merge(var.tags, {
    Module      = "unity-s3"
    Environment = var.environment
    Project     = var.project
  })
}

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = local.tags
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count = var.encryption_enabled ? 1 : 0

  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
    }
    bucket_key_enabled = var.kms_key_id != null ? true : false
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# Lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix
          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days                         = expiration.value.days
          date                         = expiration.value.date
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions != null ? rule.value.transitions : []
        content {
          days          = transition.value.days
          date          = transition.value.date
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions != null ? rule.value.noncurrent_version_transitions : []
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}

# CORS configuration
resource "aws_s3_bucket_cors_configuration" "main" {
  count = length(var.cors_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# Bucket notification
resource "aws_s3_bucket_notification" "main" {
  count = length(var.notifications) > 0 ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "lambda_function" {
    for_each = { for k, v in var.notifications : k => v if v.type == "lambda" }
    content {
      lambda_function_arn = lambda_function.value.destination_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  dynamic "topic" {
    for_each = { for k, v in var.notifications : k => v if v.type == "sns" }
    content {
      topic_arn     = topic.value.destination_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = { for k, v in var.notifications : k => v if v.type == "sqs" }
    content {
      queue_arn     = queue.value.destination_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }
}

# Bucket logging (access logs)
resource "aws_s3_bucket_logging" "main" {
  count = var.logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.main.id

  target_bucket = var.access_log_bucket != null ? var.access_log_bucket : aws_s3_bucket.main.id
  target_prefix = var.access_log_prefix
}

# Bucket policy
resource "aws_s3_bucket_policy" "main" {
  count = var.bucket_policy != null ? 1 : 0

  bucket = aws_s3_bucket.main.id
  policy = var.bucket_policy
}

# Replication configuration
resource "aws_s3_bucket_replication_configuration" "main" {
  count = var.replication_configuration != null ? 1 : 0

  role   = var.replication_configuration.role
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.replication_configuration.rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix
          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      destination {
        bucket        = rule.value.destination.bucket
        storage_class = rule.value.destination.storage_class

        dynamic "encryption_configuration" {
          for_each = rule.value.destination.replica_kms_key_id != null ? [rule.value.destination.replica_kms_key_id] : []
          content {
            replica_kms_key_id = encryption_configuration.value
          }
        }
      }

      dynamic "delete_marker_replication" {
        for_each = rule.value.delete_marker_replication_status != null ? [rule.value.delete_marker_replication_status] : []
        content {
          status = delete_marker_replication.value
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}

# CloudWatch metric filters (optional)
resource "aws_cloudwatch_log_metric_filter" "s3_access" {
  count = var.enable_access_monitoring ? 1 : 0

  name           = "${var.bucket_name}-access-filter"
  log_group_name = "/aws/s3/${var.bucket_name}"
  pattern        = "[timestamp, request_id, remote_ip, requester, bucket, key, request_uri, http_status, error_code, bytes_sent, object_size, total_time, turn_around_time, referrer, user_agent, version_id, host_id, signature_version, cipher_suite, authentication_type, host_header, tls_version]"

  metric_transformation {
    name      = "${var.bucket_name}-access-count"
    namespace = "Unity/S3"
    value     = "1"
  }
}