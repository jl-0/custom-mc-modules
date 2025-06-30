# Unity S3 Module

This module creates an S3 bucket with Unity best practices and security configurations.

## Features

- **Security First**: Block public access by default, encryption enabled
- **Lifecycle Management**: Configurable lifecycle rules for cost optimization
- **Monitoring**: Optional CloudWatch monitoring and access logging
- **Compliance**: Versioning, replication, and object lock support
- **Flexibility**: CORS, notifications, and website hosting configurations

## Usage

### Basic Example

```hcl
module "unity_bucket" {
  source = "github.com/unity-sds/terraform-modules//modules/s3?ref=v1.0.0"

  bucket_name = "unity-example-bucket"
  environment = "dev"
  project     = "unity"
}
```

### Advanced Example with Lifecycle Rules

```hcl
module "unity_data_bucket" {
  source = "github.com/unity-sds/terraform-modules//modules/s3?ref=v1.0.0"

  bucket_name         = "unity-data-storage"
  environment         = "prod"
  project             = "unity"
  versioning_enabled  = true
  encryption_enabled  = true
  kms_key_id         = aws_kms_key.bucket_key.arn

  lifecycle_rules = [
    {
      id      = "data-lifecycle"
      enabled = true
      filter = {
        prefix = "data/"
      }
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 365
      }
    }
  ]

  tags = {
    Owner       = "data-team"
    CostCenter  = "engineering"
    Backup      = "required"
  }
}
```

### Website Hosting Example

```hcl
module "unity_website" {
  source = "github.com/unity-sds/terraform-modules//modules/s3?ref=v1.0.0"

  bucket_name           = "unity-website-bucket"
  environment           = "prod"
  project               = "unity"
  block_public_access   = false

  website_configuration = {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rules = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      max_age_seconds = 3000
    }
  ]
}
```

### Data Pipeline with Notifications

```hcl
module "unity_pipeline_bucket" {
  source = "github.com/unity-sds/terraform-modules//modules/s3?ref=v1.0.0"

  bucket_name = "unity-pipeline-data"
  environment = "prod"
  project     = "unity"

  notifications = {
    lambda_trigger = {
      type            = "lambda"
      destination_arn = aws_lambda_function.data_processor.arn
      events          = ["s3:ObjectCreated:*"]
      filter_prefix   = "incoming/"
    }
  }

  enable_access_monitoring = true
  logging_enabled         = true
}
```

## Unity Management Console Integration

This module is designed to work seamlessly with the Unity Management Console. When using the console, you can reference this module in your application installations:

```json
{
  "moduleReferences": {
    "data_bucket": {
      "source": "unity-s3",
      "version": "1.0.0",
      "inputs": {
        "bucket_name": "my-unity-data-bucket",
        "environment": "dev",
        "enable_standard_lifecycle": true
      }
    }
  }
}
```

## Standard Unity Configurations

### Enable Standard Lifecycle

```hcl
module "unity_bucket" {
  source = "github.com/unity-sds/terraform-modules//modules/s3?ref=v1.0.0"

  bucket_name               = "unity-standard-bucket"
  enable_standard_lifecycle = true
  
  standard_lifecycle_config = {
    transition_to_ia_days      = 30
    transition_to_glacier_days = 90
    expire_days                = 365
    expire_noncurrent_days     = 30
  }
}
```

This creates the following lifecycle rules:
- Transition to IA after 30 days
- Transition to Glacier after 90 days
- Delete objects after 365 days
- Delete non-current versions after 30 days

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Resources

| Name | Type |
|------|------|
| aws_s3_bucket.main | resource |
| aws_s3_bucket_versioning.main | resource |
| aws_s3_bucket_server_side_encryption_configuration.main | resource |
| aws_s3_bucket_public_access_block.main | resource |
| aws_s3_bucket_lifecycle_configuration.main | resource |
| aws_s3_bucket_cors_configuration.main | resource |
| aws_s3_bucket_notification.main | resource |
| aws_s3_bucket_logging.main | resource |
| aws_s3_bucket_policy.main | resource |
| aws_s3_bucket_replication_configuration.main | resource |
| aws_cloudwatch_log_metric_filter.s3_access | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| project | Project name | `string` | `"unity"` | no |
| versioning_enabled | Enable versioning on the bucket | `bool` | `true` | no |
| encryption_enabled | Enable server-side encryption | `bool` | `true` | no |
| kms_key_id | KMS key ID for encryption (if null, uses AES256) | `string` | `null` | no |
| block_public_access | Block all public access to the bucket | `bool` | `true` | no |
| force_destroy | Allow the bucket to be destroyed even if it contains objects | `bool` | `false` | no |
| lifecycle_rules | List of lifecycle rules for the bucket | `list(object)` | `[]` | no |
| cors_rules | List of CORS rules for the bucket | `list(object)` | `[]` | no |
| notifications | Map of S3 bucket notifications | `map(object)` | `{}` | no |
| logging_enabled | Enable access logging for the bucket | `bool` | `false` | no |
| access_log_bucket | Bucket to store access logs (if null, uses same bucket) | `string` | `null` | no |
| access_log_prefix | Prefix for access log objects | `string` | `"access-logs/"` | no |
| bucket_policy | IAM policy document to attach to the bucket | `string` | `null` | no |
| replication_configuration | Replication configuration for the bucket | `object` | `null` | no |
| enable_access_monitoring | Enable CloudWatch monitoring for S3 access | `bool` | `false` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| enable_standard_lifecycle | Enable standard Unity lifecycle configuration | `bool` | `false` | no |
| standard_lifecycle_config | Standard Unity lifecycle configuration | `object` | `{}` | no |
| website_configuration | Website configuration for the bucket | `object` | `null` | no |
| transfer_acceleration_enabled | Enable transfer acceleration for the bucket | `bool` | `false` | no |
| request_payer | Specifies who should bear the cost of Amazon S3 data transfer | `string` | `"BucketOwner"` | no |
| object_lock_configuration | Object lock configuration for the bucket | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the bucket |
| bucket_arn | The ARN of the bucket |
| bucket_domain_name | The bucket domain name |
| bucket_regional_domain_name | The bucket region-specific domain name |
| bucket_hosted_zone_id | The Route 53 Hosted Zone ID for this bucket's region |
| bucket_region | The AWS region this bucket resides in |
| bucket_website_endpoint | The website endpoint, if the bucket is configured with a website |
| bucket_website_domain | The domain of the website endpoint |
| versioning_enabled | Whether versioning is enabled on the bucket |
| encryption_enabled | Whether server-side encryption is enabled |
| kms_key_id | The KMS key ID used for encryption |
| public_access_blocked | Whether public access is blocked |
| bucket_url_s3 | S3 protocol URL of the bucket |
| console_url | AWS Console URL for the bucket |

## Security Considerations

- **Default Security**: Public access is blocked by default
- **Encryption**: Server-side encryption is enabled by default
- **Versioning**: Object versioning is enabled by default
- **Access Logging**: Can be enabled for audit purposes
- **Monitoring**: CloudWatch monitoring available for access patterns

## Cost Optimization

- **Lifecycle Rules**: Automatically transition objects to cheaper storage classes
- **Standard Lifecycle**: Pre-configured Unity lifecycle rules
- **Expiration**: Automatically delete old objects and versions
- **Monitoring**: Track access patterns to optimize storage classes

## Best Practices

1. **Naming**: Use descriptive, consistent bucket names
2. **Tagging**: Always include environment, project, and owner tags
3. **Lifecycle**: Implement lifecycle rules for cost optimization
4. **Monitoring**: Enable access logging for security auditing
5. **Encryption**: Use KMS keys for sensitive data
6. **Versioning**: Enable versioning for important data
7. **Backup**: Consider cross-region replication for critical data

## License

This module is part of the Unity Science Data System (SDS) and is licensed under the Apache License 2.0.