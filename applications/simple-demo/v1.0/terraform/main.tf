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
  source  = "management-console.com/unity/s3/aws"
  version = "~> 1.0"
  
  bucket_name         = "${local.name_prefix}-user-uploads"
  environment         = var.environment
  project             = var.project_name
  versioning_enabled  = true
  encryption_enabled  = true
  block_public_access = true
  
  # Standard Unity lifecycle for user uploads
  enable_standard_lifecycle = true
  
  tags = merge(local.common_tags, {
    Purpose            = "UserUploads"
    DataClassification = "Internal"
    Backup             = "required"
  })
}
