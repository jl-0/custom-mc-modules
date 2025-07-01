# Unity Marketplace Example - Direct Terraform Usage
# This demonstrates how to use Unity S3 modules directly with Terraform

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  
  backend "s3" {
    # Configure with terraform init -backend-config="bucket=your-state-bucket"
    key     = "marketplace/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
      CostCenter  = var.cost_center
    }
  }
}

# Local values for resource naming and common configurations
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}

# User Uploads Bucket - For user-generated content
module "user_uploads_bucket" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/s3?ref=main"
  
  bucket_name         = "${local.name_prefix}-user-uploads"
  environment         = var.environment
  project             = var.project_name
  versioning_enabled  = true
  encryption_enabled  = true
  block_public_access = true
  
  # Standard Unity lifecycle for user uploads
  enable_standard_lifecycle = true
  standard_lifecycle_config = {
    transition_to_ia_days      = 30
    transition_to_glacier_days = 90
    expire_days                = 365
    expire_noncurrent_days     = 30
  }
  
  # Enable monitoring and logging for security
  enable_access_monitoring = var.enable_monitoring
  logging_enabled         = var.enable_logging
  access_log_prefix       = "user-uploads-access-logs/"
  
  # S3 notifications for virus scanning (if Lambda function exists)
  notifications = var.enable_virus_scanning ? {
    virus_scan = {
      type            = "lambda"
      destination_arn = var.virus_scanner_lambda_arn
      events          = ["s3:ObjectCreated:*"]
      filter_prefix   = "uploads/"
    }
  } : {}
  
  tags = merge(local.common_tags, {
    Purpose            = "UserUploads"
    DataClassification = "Internal"
    Backup             = "required"
  })
}

# Marketplace Data Bucket - For application data and metadata
module "marketplace_data_bucket" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/s3?ref=main"
  
  bucket_name         = "${local.name_prefix}-data"
  environment         = var.environment
  project             = var.project_name
  versioning_enabled  = true
  encryption_enabled  = true
  block_public_access = true
  
  # Custom lifecycle rules for marketplace data
  lifecycle_rules = [
    {
      id      = "marketplace-data-lifecycle"
      enabled = true
      filter = {
        prefix = "product-data/"
      }
      transitions = [
        {
          days          = 60
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        }
      ]
      noncurrent_version_expiration = {
        days = 90
      }
    }
  ]
  
  # Enable monitoring and logging
  enable_access_monitoring = var.enable_monitoring
  logging_enabled         = var.enable_logging
  access_log_prefix       = "marketplace-data-access-logs/"
  
  # Cross-region replication for backup (if enabled)
  replication_configuration = var.enable_backup ? {
    role = aws_iam_role.replication[0].arn
    rules = [
      {
        id     = "replicate-to-backup-region"
        status = "Enabled"
        destination = {
          bucket        = aws_s3_bucket.backup[0].arn
          storage_class = "STANDARD_IA"
        }
      }
    ]
  } : null
  
  tags = merge(local.common_tags, {
    Purpose            = "MarketplaceData"
    DataClassification = "Confidential"
    Backup             = var.enable_backup ? "enabled" : "disabled"
    Replication        = var.enable_backup ? "enabled" : "disabled"
  })
}

# Static Assets Bucket - For website content (public)
module "static_assets_bucket" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/s3?ref=main"
  
  bucket_name         = "${local.name_prefix}-static"
  environment         = var.environment
  project             = var.project_name
  versioning_enabled  = false  # Not needed for static assets
  encryption_enabled  = true
  block_public_access = false  # Allow public read for website
  
  # Website hosting configuration
  website_configuration = {
    index_document = "index.html"
    error_document = "error.html"
  }
  
  # CORS configuration for web access
  cors_rules = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
  
  # Lifecycle for static assets
  lifecycle_rules = [
    {
      id      = "static-assets-lifecycle"
      enabled = true
      filter = {
        prefix = "assets/"
      }
      transitions = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        }
      ]
    }
  ]
  
  # Public read policy for website assets
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${local.name_prefix}-static/*"
      }
    ]
  })
  
  # Enable transfer acceleration for faster uploads
  transfer_acceleration_enabled = var.enable_transfer_acceleration
  
  tags = merge(local.common_tags, {
    Purpose            = "StaticAssets"
    DataClassification = "Public"
    CDN                = var.enable_cdn ? "enabled" : "disabled"
  })
}

# Cross-region backup bucket (optional)
resource "aws_s3_bucket" "backup" {
  count = var.enable_backup ? 1 : 0
  
  bucket        = "${local.name_prefix}-data-backup-${var.backup_region}"
  force_destroy = var.force_destroy
  
  tags = merge(local.common_tags, {
    Purpose = "BackupStorage"
    Type    = "ReplicationDestination"
  })
}

resource "aws_s3_bucket_versioning" "backup" {
  count = var.enable_backup ? 1 : 0
  
  bucket = aws_s3_bucket.backup[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAM role for S3 replication
resource "aws_iam_role" "replication" {
  count = var.enable_backup ? 1 : 0
  
  name = "${local.name_prefix}-s3-replication-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.common_tags
}

resource "aws_iam_role_policy" "replication" {
  count = var.enable_backup ? 1 : 0
  
  name = "${local.name_prefix}-s3-replication-policy"
  role = aws_iam_role.replication[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${module.marketplace_data_bucket.bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = module.marketplace_data_bucket.bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${aws_s3_bucket.backup[0].arn}/*"
      }
    ]
  })
}