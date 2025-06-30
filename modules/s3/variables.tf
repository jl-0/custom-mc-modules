# Variables for Unity S3 Module

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  
  validation {
    condition = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name)) && length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters, start and end with lowercase letters or numbers, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "unity"
}

variable "versioning_enabled" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (if null, uses AES256)"
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "Block all public access to the bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow the bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type = list(object({
    id      = string
    enabled = bool
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    expiration = optional(object({
      days                         = optional(number)
      date                         = optional(string)
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_expiration = optional(object({
      days = number
    }))
    transitions = optional(list(object({
      days          = optional(number)
      date          = optional(string)
      storage_class = string
    })))
    noncurrent_version_transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = []
}

variable "cors_rules" {
  description = "List of CORS rules for the bucket"
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "notifications" {
  description = "Map of S3 bucket notifications"
  type = map(object({
    type            = string # lambda, sns, or sqs
    destination_arn = string
    events          = list(string)
    filter_prefix   = optional(string)
    filter_suffix   = optional(string)
  }))
  default = {}
}

variable "logging_enabled" {
  description = "Enable access logging for the bucket"
  type        = bool
  default     = false
}

variable "access_log_bucket" {
  description = "Bucket to store access logs (if null, uses same bucket)"
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Prefix for access log objects"
  type        = string
  default     = "access-logs/"
}

variable "bucket_policy" {
  description = "IAM policy document to attach to the bucket"
  type        = string
  default     = null
}

variable "replication_configuration" {
  description = "Replication configuration for the bucket"
  type = object({
    role = string
    rules = list(object({
      id     = string
      status = string
      filter = optional(object({
        prefix = optional(string)
        tags   = optional(map(string))
      }))
      destination = object({
        bucket               = string
        storage_class        = optional(string)
        replica_kms_key_id   = optional(string)
      })
      delete_marker_replication_status = optional(string)
    }))
  })
  default = null
}

variable "enable_access_monitoring" {
  description = "Enable CloudWatch monitoring for S3 access"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Common lifecycle configurations
variable "enable_standard_lifecycle" {
  description = "Enable standard Unity lifecycle configuration"
  type        = bool
  default     = false
}

variable "standard_lifecycle_config" {
  description = "Standard Unity lifecycle configuration"
  type = object({
    transition_to_ia_days      = optional(number, 30)
    transition_to_glacier_days = optional(number, 90)
    expire_days                = optional(number, 365)
    expire_noncurrent_days     = optional(number, 30)
  })
  default = {}
}

# Web hosting configuration
variable "website_configuration" {
  description = "Website configuration for the bucket"
  type = object({
    index_document = string
    error_document = optional(string)
    routing_rules  = optional(string)
  })
  default = null
}

# Transfer acceleration
variable "transfer_acceleration_enabled" {
  description = "Enable transfer acceleration for the bucket"
  type        = bool
  default     = false
}

# Request payer
variable "request_payer" {
  description = "Specifies who should bear the cost of Amazon S3 data transfer"
  type        = string
  default     = "BucketOwner"
  
  validation {
    condition     = contains(["BucketOwner", "Requester"], var.request_payer)
    error_message = "Request payer must be either 'BucketOwner' or 'Requester'."
  }
}

# Object lock configuration
variable "object_lock_configuration" {
  description = "Object lock configuration for the bucket"
  type = object({
    object_lock_enabled = string
    rule = optional(object({
      default_retention = object({
        mode  = string
        days  = optional(number)
        years = optional(number)
      })
    }))
  })
  default = null
}