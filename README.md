# Unity Terraform Modules

Official Terraform module registry for the Unity Science Data System (SDS), providing reusable infrastructure components for deploying Unity applications on AWS.

[![Documentation](https://img.shields.io/badge/docs-github--pages-blue)](https://unity-sds.github.io/unity-terraform-modules)
[![Module Registry](https://img.shields.io/badge/registry-json-green)](https://raw.githubusercontent.com/unity-sds/unity-terraform-modules/main/module-registry.json)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.0-blue)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/aws%20provider-%3E%3D4.0-orange)](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Overview

This repository contains a collection of Terraform modules designed specifically for Unity SDS applications. These modules follow Unity best practices for security, tagging, monitoring, and cost optimization.

### Key Features

- **🔒 Security First**: All modules implement security best practices by default
- **🏷️ Consistent Tagging**: Standardized tagging for cost tracking and resource management
- **📊 Monitoring Ready**: Built-in CloudWatch monitoring and logging capabilities
- **💰 Cost Optimized**: Lifecycle policies and resource optimization included
- **🔧 Unity Integration**: Seamless integration with Unity Management Console
- **📚 Well Documented**: Comprehensive documentation and examples

## Available Modules

| Module | Description | Category | Version |
|--------|-------------|----------|---------|
| [unity-s3](modules/s3/) | S3 bucket with security and lifecycle management | Storage | [![Latest](https://img.shields.io/github/v/tag/unity-sds/unity-terraform-modules?label=latest)](https://github.com/unity-sds/unity-terraform-modules/releases) |
| [unity-vpc](modules/vpc/) | VPC with public/private subnets and NAT gateways | Networking | [![Latest](https://img.shields.io/github/v/tag/unity-sds/unity-terraform-modules?label=latest)](https://github.com/unity-sds/unity-terraform-modules/releases) |
| [unity-iam](modules/iam/) | IAM roles and policies for common use cases | Security | [![Latest](https://img.shields.io/github/v/tag/unity-sds/unity-terraform-modules?label=latest)](https://github.com/unity-sds/unity-terraform-modules/releases) |
| [unity-rds](modules/rds/) | RDS database with backup and security configurations | Database | [![Latest](https://img.shields.io/github/v/tag/unity-sds/unity-terraform-modules?label=latest)](https://github.com/unity-sds/unity-terraform-modules/releases) |

## Quick Start

### 1. Basic Usage

```hcl
# Simple S3 bucket
module "unity_bucket" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/s3?ref=v1.0.0"

  bucket_name = "unity-example-bucket"
  environment = "dev"
  project     = "unity"
}

# VPC with subnets
module "unity_vpc" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/vpc?ref=v1.0.0"

  vpc_cidr           = "10.0.0.0/16"
  name_prefix        = "unity-dev"
  availability_zones = ["us-west-2a", "us-west-2b"]
}
```

### 2. Complete Infrastructure Example

```hcl
# VPC
module "unity_vpc" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/vpc?ref=v1.0.0"

  vpc_cidr           = "10.0.0.0/16"
  name_prefix        = "unity-prod"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}

# S3 Bucket with lifecycle
module "unity_data_bucket" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/s3?ref=v1.0.0"

  bucket_name               = "unity-data-storage"
  environment               = "prod"
  project                   = "unity"
  enable_standard_lifecycle = true
  
  standard_lifecycle_config = {
    transition_to_ia_days      = 30
    transition_to_glacier_days = 90
    expire_days                = 365
  }
}

# Database
module "unity_database" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/rds?ref=v1.0.0"

  identifier     = "unity-prod-db"
  engine         = "postgres"
  instance_class = "db.r5.large"
  vpc_id         = module.unity_vpc.vpc_id
  subnet_ids     = module.unity_vpc.private_subnet_ids
}
```

## Unity Management Console Integration

These modules are designed to work seamlessly with the [Unity Management Console](https://github.com/unity-sds/unity-management-console). The console can automatically discover and use these modules through the [module registry](module-registry.json).

### Using with Management Console

1. **Automatic Discovery**: The console automatically loads the module registry
2. **Application Installation**: Reference modules in your application installations
3. **Parameter Management**: Configure module inputs through the console UI

```json
{
  "moduleReferences": {
    "data_storage": {
      "source": "unity-s3",
      "version": "1.0.0",
      "inputs": {
        "bucket_name": "my-unity-data",
        "environment": "dev",
        "enable_standard_lifecycle": true
      }
    },
    "network": {
      "source": "unity-vpc",
      "version": "1.0.0",
      "inputs": {
        "vpc_cidr": "10.0.0.0/16",
        "name_prefix": "my-unity",
        "availability_zones": ["us-west-2a", "us-west-2b"]
      }
    }
  }
}
```

## Module Categories

### 🗄️ Storage
- **unity-s3**: Secure S3 buckets with lifecycle management, encryption, and monitoring

### 🌐 Networking  
- **unity-vpc**: Production-ready VPC with public/private subnets, NAT gateways, and routing

### 🔒 Security
- **unity-iam**: IAM roles and policies following least privilege principles

### 🗃️ Database
- **unity-rds**: RDS instances with automated backups, encryption, and monitoring

## Development

### Module Structure

Each module follows a consistent structure:

```
modules/
├── <module-name>/
│   ├── main.tf          # Main resources
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # Output values
│   ├── README.md        # Documentation
│   └── versions.tf      # Provider requirements
```

### Contributing a New Module

1. **Create Module Structure**:
   ```bash
   mkdir -p modules/my-module
   cd modules/my-module
   ```

2. **Follow Unity Standards**:
   - Use consistent variable naming
   - Include comprehensive tags
   - Implement security best practices
   - Add monitoring capabilities

3. **Update Registry**:
   - Add module to `module-registry.json`
   - Include version information
   - Document inputs/outputs

4. **Documentation**:
   - Write comprehensive README
   - Include usage examples
   - Document best practices

### Testing

```bash
# Validate all modules
terraform fmt -check -recursive modules/
terraform validate modules/*/

# Run security scans
checkov --directory modules/
trivy config modules/

# Test specific module
cd modules/s3
terraform init
terraform plan
```

## Documentation

- **📖 [Module Documentation](https://unity-sds.github.io/unity-terraform-modules)**: Complete module reference
- **📋 [Module Registry](module-registry.json)**: Machine-readable module catalog
- **🎯 [Examples](examples/)**: Usage examples and patterns
- **🔧 [Unity Management Console Guide](https://github.com/unity-sds/unity-management-console/blob/main/documentation/module-registry-guide.md)**

## Versioning

This project uses [Semantic Versioning](https://semver.org/):

- **Major**: Breaking changes to module interfaces
- **Minor**: New modules or backward-compatible features  
- **Patch**: Bug fixes and documentation updates

### Using Specific Versions

```hcl
# Use specific version (recommended for production)
module "unity_bucket" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/s3?ref=v1.0.0"
  # ...
}

# Use latest (for development)
module "unity_bucket" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/s3?ref=main"
  # ...
}
```

## Requirements

- **Terraform**: >= 1.0
- **AWS Provider**: >= 4.0
- **AWS CLI**: For authentication and testing

## Support

- **🐛 Issues**: [GitHub Issues](https://github.com/unity-sds/unity-terraform-modules/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/unity-sds/unity-terraform-modules/discussions)
- **📧 Contact**: unity-sds-support@jpl.nasa.gov

## Security

Security is a top priority for Unity modules:

- **🔐 Encryption**: Enabled by default where applicable
- **🚫 Public Access**: Blocked by default for storage resources
- **🏷️ Access Control**: Least privilege IAM policies
- **📊 Monitoring**: CloudWatch integration for security events
- **🔍 Scanning**: Automated security scans on all commits

Report security vulnerabilities to: unity-sds-security@jpl.nasa.gov

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

---

**Unity Science Data System (SDS)**  
Jet Propulsion Laboratory, California Institute of Technology

[![Unity SDS](https://img.shields.io/badge/Unity-SDS-blue)](https://unity-sds.gitbook.io/docs/)
[![JPL](https://img.shields.io/badge/JPL-NASA-red)](https://www.jpl.nasa.gov/)