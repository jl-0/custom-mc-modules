# Outputs for Unity S3 Module

output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region"
  value       = aws_s3_bucket.main.hosted_zone_id
}

output "bucket_region" {
  description = "The AWS region this bucket resides in"
  value       = aws_s3_bucket.main.region
}

output "bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website"
  value       = var.website_configuration != null ? aws_s3_bucket.main.website_endpoint : null
}

output "bucket_website_domain" {
  description = "The domain of the website endpoint"
  value       = var.website_configuration != null ? aws_s3_bucket.main.website_domain : null
}

# Versioning outputs
output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket"
  value       = var.versioning_enabled
}

# Encryption outputs
output "encryption_enabled" {
  description = "Whether server-side encryption is enabled"
  value       = var.encryption_enabled
}

output "kms_key_id" {
  description = "The KMS key ID used for encryption"
  value       = var.kms_key_id
}

# Public access block outputs
output "public_access_blocked" {
  description = "Whether public access is blocked"
  value       = var.block_public_access
}

# Lifecycle configuration
output "lifecycle_rules_count" {
  description = "Number of lifecycle rules configured"
  value       = length(var.lifecycle_rules)
}

# CORS configuration
output "cors_rules_count" {
  description = "Number of CORS rules configured"
  value       = length(var.cors_rules)
}

# Notification outputs
output "notifications_configured" {
  description = "Map of configured notifications"
  value       = var.notifications
}

# Logging outputs
output "logging_enabled" {
  description = "Whether access logging is enabled"
  value       = var.logging_enabled
}

output "access_log_bucket" {
  description = "Bucket used for access logs"
  value       = var.access_log_bucket
}

# Policy outputs
output "has_bucket_policy" {
  description = "Whether a bucket policy is attached"
  value       = var.bucket_policy != null
}

# Replication outputs
output "replication_enabled" {
  description = "Whether replication is configured"
  value       = var.replication_configuration != null
}

# Monitoring outputs
output "access_monitoring_enabled" {
  description = "Whether CloudWatch access monitoring is enabled"
  value       = var.enable_access_monitoring
}

# Standard lifecycle outputs
output "standard_lifecycle_enabled" {
  description = "Whether standard Unity lifecycle is enabled"
  value       = var.enable_standard_lifecycle
}

# Website hosting outputs
output "website_hosting_enabled" {
  description = "Whether website hosting is configured"
  value       = var.website_configuration != null
}

# Transfer acceleration outputs
output "transfer_acceleration_enabled" {
  description = "Whether transfer acceleration is enabled"
  value       = var.transfer_acceleration_enabled
}

# Object lock outputs
output "object_lock_enabled" {
  description = "Whether object lock is enabled"
  value       = var.object_lock_configuration != null ? var.object_lock_configuration.object_lock_enabled : "Disabled"
}

# Tags output
output "tags" {
  description = "Tags applied to the bucket"
  value       = local.tags
}

# Bucket URL for different protocols
output "bucket_url_http" {
  description = "HTTP URL of the bucket"
  value       = "http://${aws_s3_bucket.main.bucket_domain_name}"
}

output "bucket_url_https" {
  description = "HTTPS URL of the bucket"
  value       = "https://${aws_s3_bucket.main.bucket_domain_name}"
}

output "bucket_url_s3" {
  description = "S3 protocol URL of the bucket"
  value       = "s3://${aws_s3_bucket.main.id}"
}

# Console URL
output "console_url" {
  description = "AWS Console URL for the bucket"
  value       = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.main.id}"
}