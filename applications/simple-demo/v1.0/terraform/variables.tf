# Variables for Unity Marketplace Example

# Basic Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "marketplace"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "owner" {
  description = "Owner of the resources (for tagging and cost allocation)"
  type        = string
  default     = "marketplace-team"
}

variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  default     = "engineering"
}

# S3 Configuration
variable "force_destroy" {
  description = "Allow destruction of S3 buckets even if they contain objects"
  type        = bool
  default     = false
}

# Feature Flags
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring for S3 buckets"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable cross-region replication for backup"
  type        = bool
  default     = false
}

variable "enable_virus_scanning" {
  description = "Enable virus scanning for uploaded files"
  type        = bool
  default     = false
}

variable "enable_transfer_acceleration" {
  description = "Enable S3 transfer acceleration for faster uploads"
  type        = bool
  default     = false
}

variable "enable_cdn" {
  description = "Enable CloudFront CDN for static assets"
  type        = bool
  default     = false
}

# Backup Configuration
variable "backup_region" {
  description = "AWS region for backup replication"
  type        = string
  default     = "us-east-1"
}

# Lambda Configuration (if virus scanning is enabled)
variable "virus_scanner_lambda_arn" {
  description = "ARN of Lambda function for virus scanning"
  type        = string
  default     = ""
}

# Advanced S3 Configuration
variable "lifecycle_transition_days" {
  description = "Number of days before transitioning objects to cheaper storage classes"
  type = object({
    to_ia      = optional(number, 30)
    to_glacier = optional(number, 90)
  })
  default = {
    to_ia      = 30
    to_glacier = 90
  }
}

variable "object_expiration_days" {
  description = "Number of days before objects expire and are deleted"
  type        = number
  default     = 365
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days before non-current object versions are deleted"
  type        = number
  default     = 30
}

# Custom Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Security Configuration
variable "kms_key_id" {
  description = "KMS key ID for S3 bucket encryption (if null, uses AES256)"
  type        = string
  default     = null
}

variable "enable_object_lock" {
  description = "Enable S3 Object Lock for compliance"
  type        = bool
  default     = false
}

variable "object_lock_retention_years" {
  description = "Years to retain objects when Object Lock is enabled"
  type        = number
  default     = 1
}

# Notification Configuration
variable "notification_lambda_functions" {
  description = "Map of Lambda functions to trigger on S3 events"
  type = map(object({
    function_arn  = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default = {}
}

variable "notification_sns_topics" {
  description = "Map of SNS topics to trigger on S3 events"
  type = map(object({
    topic_arn     = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default = {}
}

variable "notification_sqs_queues" {
  description = "Map of SQS queues to trigger on S3 events"
  type = map(object({
    queue_arn     = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default = {}
}

# CORS Configuration for Static Assets
variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allowed_methods" {
  description = "List of allowed HTTP methods for CORS"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cors_max_age_seconds" {
  description = "Maximum age in seconds for CORS preflight requests"
  type        = number
  default     = 3000
}

# Website Configuration
variable "website_index_document" {
  description = "Index document for S3 website hosting"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "Error document for S3 website hosting"
  type        = string
  default     = "error.html"
}

# Environment-specific Configurations
variable "environment_configs" {
  description = "Environment-specific configuration overrides"
  type = map(object({
    monitoring_enabled           = optional(bool)
    backup_enabled              = optional(bool)
    transfer_acceleration       = optional(bool)
    lifecycle_transition_ia     = optional(number)
    lifecycle_transition_glacier = optional(number)
    object_expiration_days      = optional(number)
  }))
  default = {
    dev = {
      monitoring_enabled           = true
      backup_enabled              = false
      transfer_acceleration       = false
      lifecycle_transition_ia     = 30
      lifecycle_transition_glacier = 90
      object_expiration_days      = 180
    }
    staging = {
      monitoring_enabled           = true
      backup_enabled              = true
      transfer_acceleration       = false
      lifecycle_transition_ia     = 30
      lifecycle_transition_glacier = 90
      object_expiration_days      = 365
    }
    prod = {
      monitoring_enabled           = true
      backup_enabled              = true
      transfer_acceleration       = true
      lifecycle_transition_ia     = 30
      lifecycle_transition_glacier = 90
      object_expiration_days      = 2555  # 7 years
    }
  }
}