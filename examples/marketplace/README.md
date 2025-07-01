# Unity Marketplace Example

This example demonstrates how to deploy a simple marketplace application using Unity Terraform modules with the Unity Management Console.

## Overview

This marketplace example showcases:

- **S3 Storage**: Data storage for marketplace items, user uploads, and static assets
- **Module Registry Integration**: Using modules from the Unity Management Console
- **Best Practices**: Unity-standard configurations for security and compliance
- **Multi-environment Support**: Configuration for dev, staging, and production deployments

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Uploads  │    │  Marketplace    │    │  Static Assets  │
│   S3 Bucket     │    │  Data Bucket    │    │   S3 Bucket     │
│                 │    │                 │    │                 │
│ - User content  │    │ - Product data  │    │ - Images        │
│ - Versioned     │    │ - Lifecycle     │    │ - CSS/JS files  │
│ - Encrypted     │    │ - Monitoring    │    │ - Website       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Files Structure

```
marketplace/
├── README.md                        # This file
├── module-registry.json             # Module definitions for Unity Management Console
├── install-marketplace-app.json     # Application installation configuration
├── unity-config-marketplace.yaml    # Unity platform configuration
├── marketplace-config.yaml          # Marketplace-specific settings
└── terraform/                       # Direct Terraform usage examples
    ├── main.tf                      # Main Terraform configuration
    ├── variables.tf                 # Input variables
    └── outputs.tf                   # Output values
```

## Quick Start

### Using Unity Management Console

1. **Deploy via Management Console**:
   ```bash
   # Use the install-marketplace-app.json with Unity Management Console
   unity-console deploy --config install-marketplace-app.json
   ```

2. **Verify Deployment**:
   ```bash
   # Check deployment status
   unity-console status --deployment marketplace-demo
   ```

### Using Terraform Directly

1. **Navigate to terraform directory**:
   ```bash
   cd terraform/
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan deployment**:
   ```bash
   terraform plan -var="environment=dev" -var="project_name=marketplace-demo"
   ```

4. **Apply configuration**:
   ```bash
   terraform apply
   ```

## Module Usage

### S3 Storage Buckets

The example creates three S3 buckets optimized for different marketplace use cases:

#### 1. User Uploads Bucket
- **Purpose**: Store user-uploaded content (documents, images, etc.)
- **Features**: Versioning, encryption, lifecycle management
- **Access**: Restricted, authenticated users only

#### 2. Marketplace Data Bucket  
- **Purpose**: Store marketplace product data, catalogs, metadata
- **Features**: Cross-region replication, monitoring, backup lifecycle
- **Access**: Application services only

#### 3. Static Assets Bucket
- **Purpose**: Host static website content, images, CSS, JavaScript
- **Features**: Website hosting, CDN-ready, public read access
- **Access**: Public read for web assets

### Security Features

- **Encryption**: All buckets use AES-256 or KMS encryption
- **Access Control**: Least-privilege IAM policies
- **Monitoring**: CloudWatch metrics and access logging
- **Compliance**: Versioning and audit trails enabled

### Cost Optimization

- **Lifecycle Rules**: Automatic transition to cheaper storage classes
- **Standard Configurations**: Pre-configured Unity lifecycle policies
- **Intelligent Tiering**: Automatic cost optimization for varying access patterns

## Configuration Options

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|:--------:|
| `environment` | Deployment environment | `dev` | No |
| `project_name` | Project identifier | `marketplace` | No |
| `aws_region` | AWS region for deployment | `us-west-2` | No |
| `enable_monitoring` | Enable CloudWatch monitoring | `true` | No |
| `enable_backup` | Enable cross-region backup | `false` | No |

### Module Customization

Each S3 module can be customized through the `config` section in `install-marketplace-app.json`:

```json
{
  "config": {
    "versioning_enabled": true,
    "encryption_enabled": true,
    "enable_standard_lifecycle": true,
    "enable_access_monitoring": true,
    "tags": {
      "Owner": "marketplace-team",
      "CostCenter": "engineering"
    }
  }
}
```

## Integration with Unity Management Console

This example is designed to work with the Unity Management Console module registry system:

1. **Module Registry**: Defines available modules and their versions
2. **Application Installation**: References modules from the registry
3. **Configuration Management**: Centralized configuration through Unity config files
4. **Deployment Tracking**: Integration with Unity deployment management

### Module Registry Features

- **Version Management**: Supports semantic versioning and latest tags
- **Documentation Links**: Direct links to module documentation
- **Input Validation**: Type checking and required parameter validation
- **Output Mapping**: Clear output definitions for module chaining

## Testing

### Validation

```bash
# Validate Terraform configuration
cd terraform/
terraform validate

# Validate JSON configuration files
jsonlint install-marketplace-app.json
jsonlint module-registry.json
```

### Deployment Test

```bash
# Test deployment in development environment
unity-console deploy --config install-marketplace-app.json --dry-run
```

## Monitoring and Maintenance

### CloudWatch Metrics

Monitor your marketplace deployment:

- **S3 Bucket Metrics**: Storage usage, request patterns
- **Access Patterns**: User upload/download activity  
- **Cost Tracking**: Storage costs by bucket and lifecycle stage

### Lifecycle Management

Automatic lifecycle policies help manage costs:

- **User Uploads**: Transition to IA after 30 days, Glacier after 90 days
- **Marketplace Data**: Retain current versions, archive old versions
- **Static Assets**: Intelligent tiering based on access patterns

## Troubleshooting

### Common Issues

1. **Bucket Name Conflicts**: S3 bucket names must be globally unique
   - Solution: Customize bucket names in configuration

2. **Permission Errors**: IAM permissions for S3 access
   - Solution: Ensure proper IAM roles and policies are attached

3. **Lifecycle Transitions**: Objects not transitioning to cheaper storage
   - Solution: Check lifecycle rule configuration and object age

### Support

- **Documentation**: [Unity Terraform Modules](https://github.com/unity-sds/terraform-modules)
- **Issues**: Report issues on the [Unity Management Console repository](https://github.com/unity-sds/unity-management-console)
- **Community**: Unity SDS community forums

## License

This example is part of the Unity Science Data System (SDS) and is licensed under the Apache License 2.0.