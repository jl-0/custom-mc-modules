# Outputs for Unity Marketplace Example

# User Uploads Bucket Outputs
output "user_uploads_bucket_id" {
  description = "Name of the user uploads bucket"
  value       = module.user_uploads_bucket.bucket_id
}

output "user_uploads_bucket_arn" {
  description = "ARN of the user uploads bucket"
  value       = module.user_uploads_bucket.bucket_arn
}

output "user_uploads_bucket_domain_name" {
  description = "Domain name of the user uploads bucket"
  value       = module.user_uploads_bucket.bucket_domain_name
}

output "user_uploads_bucket_url" {
  description = "S3 URL of the user uploads bucket"
  value       = module.user_uploads_bucket.bucket_url_s3
}

output "user_uploads_console_url" {
  description = "AWS Console URL for the user uploads bucket"
  value       = module.user_uploads_bucket.console_url
}

# Configuration Summary Outputs
output "configuration_summary" {
  description = "Summary of the deployed configuration"
  value = {
    project_name      = var.project_name
    environment       = var.environment
    aws_region        = var.aws_region
    backup_enabled    = var.enable_backup
    backup_region     = var.backup_region
    monitoring_enabled = var.enable_monitoring
    logging_enabled   = var.enable_logging
    virus_scanning    = var.enable_virus_scanning
    transfer_acceleration = var.enable_transfer_acceleration
    cdn_enabled       = var.enable_cdn
  }
}

# Security Configuration Outputs
output "security_configuration" {
  description = "Security configuration details"
  value = {
    encryption_enabled = {
      user_uploads    = module.user_uploads_bucket.encryption_enabled
    }
    versioning_enabled = {
      user_uploads    = module.user_uploads_bucket.versioning_enabled
    }
    public_access_blocked = {
      user_uploads    = module.user_uploads_bucket.public_access_blocked
    }
  }
}

# Resource Tags
output "applied_tags" {
  description = "Tags applied to all resources"
  value = {
    user_uploads_tags    = module.user_uploads_bucket.tags
  }
}