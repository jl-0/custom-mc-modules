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

# Marketplace Data Bucket Outputs
output "marketplace_data_bucket_id" {
  description = "Name of the marketplace data bucket"
  value       = module.marketplace_data_bucket.bucket_id
}

output "marketplace_data_bucket_arn" {
  description = "ARN of the marketplace data bucket"
  value       = module.marketplace_data_bucket.bucket_arn
}

output "marketplace_data_bucket_domain_name" {
  description = "Domain name of the marketplace data bucket"
  value       = module.marketplace_data_bucket.bucket_domain_name
}

output "marketplace_data_bucket_url" {
  description = "S3 URL of the marketplace data bucket"
  value       = module.marketplace_data_bucket.bucket_url_s3
}

output "marketplace_data_console_url" {
  description = "AWS Console URL for the marketplace data bucket"
  value       = module.marketplace_data_bucket.console_url
}

# Static Assets Bucket Outputs
output "static_assets_bucket_id" {
  description = "Name of the static assets bucket"
  value       = module.static_assets_bucket.bucket_id
}

output "static_assets_bucket_arn" {
  description = "ARN of the static assets bucket"
  value       = module.static_assets_bucket.bucket_arn
}

output "static_assets_bucket_domain_name" {
  description = "Domain name of the static assets bucket"
  value       = module.static_assets_bucket.bucket_domain_name
}

output "static_assets_bucket_url" {
  description = "S3 URL of the static assets bucket"
  value       = module.static_assets_bucket.bucket_url_s3
}

output "static_assets_website_endpoint" {
  description = "Website endpoint for the static assets bucket"
  value       = module.static_assets_bucket.bucket_website_endpoint
}

output "static_assets_website_url" {
  description = "Full website URL for the static assets bucket"
  value       = "https://${module.static_assets_bucket.bucket_domain_name}"
}

output "static_assets_console_url" {
  description = "AWS Console URL for the static assets bucket"
  value       = module.static_assets_bucket.console_url
}

# Backup Bucket Outputs (if enabled)
output "backup_bucket_id" {
  description = "Name of the backup bucket (if backup is enabled)"
  value       = var.enable_backup ? aws_s3_bucket.backup[0].id : null
}

output "backup_bucket_arn" {
  description = "ARN of the backup bucket (if backup is enabled)"
  value       = var.enable_backup ? aws_s3_bucket.backup[0].arn : null
}

# Replication IAM Role (if backup is enabled)
output "replication_role_arn" {
  description = "ARN of the S3 replication IAM role (if backup is enabled)"
  value       = var.enable_backup ? aws_iam_role.replication[0].arn : null
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
      marketplace_data = module.marketplace_data_bucket.encryption_enabled
      static_assets   = module.static_assets_bucket.encryption_enabled
    }
    versioning_enabled = {
      user_uploads    = module.user_uploads_bucket.versioning_enabled
      marketplace_data = module.marketplace_data_bucket.versioning_enabled
      static_assets   = module.static_assets_bucket.versioning_enabled
    }
    public_access_blocked = {
      user_uploads    = module.user_uploads_bucket.public_access_blocked
      marketplace_data = module.marketplace_data_bucket.public_access_blocked
      static_assets   = module.static_assets_bucket.public_access_blocked
    }
  }
}

# Cost Optimization Outputs
output "lifecycle_configuration" {
  description = "Lifecycle configuration for cost optimization"
  value = {
    user_uploads_lifecycle = module.user_uploads_bucket.standard_lifecycle_enabled
    marketplace_data_lifecycle_rules = module.marketplace_data_bucket.lifecycle_rules_count
    static_assets_lifecycle_rules = module.static_assets_bucket.lifecycle_rules_count
  }
}

# Monitoring and Logging Outputs
output "monitoring_configuration" {
  description = "Monitoring and logging configuration"
  value = {
    access_monitoring = {
      user_uploads    = module.user_uploads_bucket.access_monitoring_enabled
      marketplace_data = module.marketplace_data_bucket.access_monitoring_enabled
      static_assets   = module.static_assets_bucket.access_monitoring_enabled
    }
    access_logging = {
      user_uploads    = module.user_uploads_bucket.logging_enabled
      marketplace_data = module.marketplace_data_bucket.logging_enabled
      static_assets   = module.static_assets_bucket.logging_enabled
    }
  }
}

# Integration Outputs
output "integration_points" {
  description = "Integration points for connecting with other services"
  value = {
    # For Lambda functions or applications
    bucket_names = {
      user_uploads    = module.user_uploads_bucket.bucket_id
      marketplace_data = module.marketplace_data_bucket.bucket_id
      static_assets   = module.static_assets_bucket.bucket_id
    }
    
    # For IAM policies
    bucket_arns = {
      user_uploads    = module.user_uploads_bucket.bucket_arn
      marketplace_data = module.marketplace_data_bucket.bucket_arn
      static_assets   = module.static_assets_bucket.bucket_arn
    }
    
    # For CloudFront or web applications
    website_endpoints = {
      static_assets = module.static_assets_bucket.bucket_website_endpoint
    }
    
    # For cross-service notifications
    notification_configurations = {
      user_uploads    = module.user_uploads_bucket.notifications_configured
      marketplace_data = module.marketplace_data_bucket.notifications_configured
      static_assets   = module.static_assets_bucket.notifications_configured
    }
  }
}

# Quick Start URLs
output "quick_start_urls" {
  description = "Quick access URLs for common tasks"
  value = {
    aws_console = {
      user_uploads_bucket    = module.user_uploads_bucket.console_url
      marketplace_data_bucket = module.marketplace_data_bucket.console_url
      static_assets_bucket   = module.static_assets_bucket.console_url
    }
    
    website_url = "https://${module.static_assets_bucket.bucket_domain_name}"
    
    s3_urls = {
      user_uploads    = module.user_uploads_bucket.bucket_url_s3
      marketplace_data = module.marketplace_data_bucket.bucket_url_s3
      static_assets   = module.static_assets_bucket.bucket_url_s3
    }
  }
}

# Resource Tags
output "applied_tags" {
  description = "Tags applied to all resources"
  value = {
    user_uploads_tags    = module.user_uploads_bucket.tags
    marketplace_data_tags = module.marketplace_data_bucket.tags
    static_assets_tags   = module.static_assets_bucket.tags
  }
}