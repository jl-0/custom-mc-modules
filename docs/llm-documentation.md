# Unity Terraform Modules - LLM Documentation

This documentation is optimized for Large Language Models (LLMs) to understand and work with Unity Terraform modules.

## Quick Reference

**Repository:** $(jq -r '.metadata.repository' module-registry.json)
**Last Updated:** $(jq -r '.metadata.last_updated' module-registry.json)
**Documentation URL:** https://jl-0.github.io/custom-mc-modules

## Available Modules

### infrastructure-s3

**Description:** Unity S3 bucket with security best practices and lifecycle management

**Source:** `github.com/jl-0/custom-mc-modules//modules/s3`

**Category:** infrastructure

**Tags:** unity, terraform

**Usage Example:**
```hcl
module "infrastructure-s3_example" {
  source = "github.com/jl-0/custom-mc-modules//modules/s3?ref=main"
  
  bucket_name = "example-value"
}
```

**Required Inputs:**
- `bucket_name` (string): Name of the S3 bucket

**Optional Inputs:**
- `environment` (string): Environment name (e.g., dev, staging, prod) (default: `dev`)
- `project` (string): Project name (default: `unity`)
- `versioning_enabled` (bool): Enable versioning on the bucket (default: `true`)
- `encryption_enabled` (bool): Enable server-side encryption (default: `true`)
- `kms_key_id` (string): KMS key ID for encryption (if null, uses AES256)
- `block_public_access` (bool): Block all public access to the bucket (default: `true`)
- `enable_standard_lifecycle` (bool): Enable standard Unity lifecycle configuration (default: `false`)
- `lifecycle_rules` (list(object)): List of custom lifecycle rules for the bucket (default: `[]`)
- `tags` (map(string)): Additional tags to apply to all resources (default: `{}`)

**Outputs:**
- `bucket_id`: The name of the bucket
- `bucket_arn`: The ARN of the bucket
- `bucket_domain_name`: The bucket domain name
- `bucket_url_s3`: S3 protocol URL of the bucket
- `console_url`: AWS Console URL for the bucket

---

### infrastructure-vpc

**Description:** Unity VPC with public/private subnets across multiple AZs

**Source:** `github.com/jl-0/custom-mc-modules//modules/vpc`

**Category:** infrastructure

**Tags:** unity, terraform

**Usage Example:**
```hcl
module "infrastructure-vpc_example" {
  source = "github.com/jl-0/custom-mc-modules//modules/vpc?ref=main"
  
  vpc_cidr = "example-value"
  name_prefix = "example-value"
  availability_zones = "example-value"
}
```

**Required Inputs:**
- `vpc_cidr` (string): CIDR block for the VPC
- `name_prefix` (string): Name prefix for all resources
- `availability_zones` (list(string)): List of availability zones

**Optional Inputs:**
- `enable_nat_gateway` (bool): Enable NAT Gateway for private subnets (default: `true`)
- `enable_dns_hostnames` (bool): Enable DNS hostnames in the VPC (default: `true`)
- `tags` (map(string)): Additional tags to apply to all resources (default: `{}`)

**Outputs:**
- `vpc_id`: The ID of the VPC
- `vpc_cidr_block`: The CIDR block of the VPC
- `public_subnet_ids`: List of public subnet IDs
- `private_subnet_ids`: List of private subnet IDs
- `nat_gateway_ids`: List of NAT Gateway IDs
- `internet_gateway_id`: The ID of the Internet Gateway

---

## Integration Patterns

### Basic Infrastructure Setup
```hcl
# Complete infrastructure with VPC and S3
module "vpc" {
  source = "github.com/jl-0/custom-mc-modules//modules/vpc?ref=main"
  
  vpc_cidr           = "10.0.0.0/16"
  name_prefix        = "my-app"
  availability_zones = ["us-west-2a", "us-west-2b"]
}

module "data_bucket" {
  source = "github.com/jl-0/custom-mc-modules//modules/s3?ref=main"
  
  bucket_name = "my-app-data-bucket"
  environment = "prod"
}
```

### Variable References Between Modules
```hcl
# Use VPC outputs in other modules
module "vpc" {
  source = "github.com/jl-0/custom-mc-modules//modules/vpc?ref=main"
  # ... configuration
}

# Reference VPC outputs (for future RDS module)
# vpc_id = module.vpc.vpc_id
# subnet_ids = module.vpc.private_subnet_ids
```

## LLM Implementation Guidelines

When helping users implement these modules:

1. **Always use the latest source reference:** `?ref=main`
2. **Include required inputs:** Check the Required Inputs section for each module
3. **Suggest appropriate defaults:** Use the documented defaults for optional inputs
4. **Consider dependencies:** VPC should be created before other networking-dependent resources
5. **Follow naming conventions:** Use consistent prefixes and environments
6. **Add appropriate tags:** Include environment, project, and purpose tags

## Common Use Cases

### Development Environment
- Use smaller instance types and simplified configurations
- Enable development-friendly settings
- Use `environment = "dev"`

### Production Environment  
- Enable all security features
- Use production-grade instance types
- Enable monitoring and logging
- Use `environment = "prod"`

### Data Processing Pipeline
- S3 bucket for data storage with lifecycle rules
- VPC with private subnets for compute resources
- Enable standard Unity lifecycle management

## Access Methods

- **Interactive Copy:** Visit https://jl-0.github.io/custom-mc-modules/#llm-docs
- **Direct Access:** https://raw.githubusercontent.com/jl-0/custom-mc-modules/main/docs/llm-documentation.md
- **Module Registry JSON:** https://raw.githubusercontent.com/jl-0/custom-mc-modules/main/module-registry.json
