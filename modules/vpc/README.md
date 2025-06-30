# Unity VPC Module

This module creates a VPC with public and private subnets across multiple availability zones, following Unity best practices for network security and high availability.

## Features

- **Multi-AZ Design**: Deploy across multiple availability zones for high availability
- **Public/Private Subnets**: Separate public and private subnets with proper routing
- **NAT Gateways**: Optional NAT gateways for outbound internet access from private subnets
- **VPC Endpoints**: Optional VPC endpoints for AWS services (S3, DynamoDB)
- **Flow Logs**: Optional VPC flow logs for network monitoring
- **Flexible Configuration**: Customizable CIDR blocks, subnets, and networking features

## Usage

### Basic Example

```hcl
module "unity_vpc" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/vpc?ref=v1.0.0"

  vpc_cidr           = "10.0.0.0/16"
  name_prefix        = "unity-dev"
  availability_zones = ["us-west-2a", "us-west-2b"]
  
  environment = "dev"
  project     = "unity"
}
```

### Production Example with All Features

```hcl
module "unity_vpc_prod" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/vpc?ref=v1.0.0"

  vpc_cidr           = "10.0.0.0/16"
  name_prefix        = "unity-prod"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  environment = "prod"
  project     = "unity"
  
  # High availability
  enable_nat_gateway = true
  one_nat_gateway_per_az = true
  
  # VPC Endpoints for cost optimization
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
  
  # Monitoring
  enable_flow_log           = true
  flow_log_destination_arn  = aws_cloudwatch_log_group.vpc_flow_log.arn
  flow_log_iam_role_arn    = aws_iam_role.flow_log.arn
  
  # VPN connectivity
  enable_vpn_gateway = true
  propagate_private_route_tables_vgw = true
  
  tags = {
    Owner       = "platform-team"
    CostCenter  = "engineering"
    Backup      = "required"
  }
}
```

### Cost-Optimized Example

```hcl
module "unity_vpc_dev" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/vpc?ref=v1.0.0"

  vpc_cidr           = "10.0.0.0/16"
  name_prefix        = "unity-dev"
  availability_zones = ["us-west-2a", "us-west-2b"]
  
  environment = "dev"
  project     = "unity"
  
  # Cost optimization - single NAT gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  
  # VPC Endpoints to reduce NAT costs
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
}
```

### Private Subnets Only

```hcl
module "unity_vpc_private" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/vpc?ref=v1.0.0"

  vpc_cidr           = "10.0.0.0/16"
  name_prefix        = "unity-private"
  availability_zones = ["us-west-2a", "us-west-2b"]
  
  # No internet gateway or NAT gateways
  create_igw         = false
  enable_nat_gateway = false
  
  # VPN gateway for connectivity
  enable_vpn_gateway = true
}
```

## Unity Management Console Integration

This module is designed to work seamlessly with the Unity Management Console. When using the console, you can reference this module in your application installations:

```json
{
  "moduleReferences": {
    "network": {
      "source": "unity-vpc",
      "version": "1.0.0",
      "inputs": {
        "vpc_cidr": "10.0.0.0/16",
        "name_prefix": "my-unity-env",
        "availability_zones": ["us-west-2a", "us-west-2b"]
      }
    }
  }
}
```

## Architecture

The module creates the following architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                           VPC                               │
│                      (10.0.0.0/16)                        │
│                                                           │
│  ┌─────────────────┐    ┌─────────────────┐               │
│  │   Public AZ-A   │    │   Public AZ-B   │               │
│  │  (10.0.0.0/24)  │    │  (10.0.1.0/24)  │               │
│  │                 │    │                 │               │
│  │  ┌───────────┐  │    │  ┌───────────┐  │               │
│  │  │ NAT GW A  │  │    │  │ NAT GW B  │  │               │
│  │  └───────────┘  │    │  └───────────┘  │               │
│  └─────────┬───────┘    └─────────┬───────┘               │
│            │                      │                       │
│     ┌──────┴──────┐        ┌──────┴──────┐                │
│     │             │        │             │                │
│  ┌──▼─────────────▼──┐  ┌──▼─────────────▼──┐              │
│  │   Private AZ-A    │  │   Private AZ-B    │              │
│  │  (10.0.10.0/24)   │  │  (10.0.11.0/24)   │              │
│  │                   │  │                   │              │
│  │   [Application    │  │   [Application    │              │
│  │    Resources]     │  │    Resources]     │              │
│  └───────────────────┘  └───────────────────┘              │
│                                                           │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────▼──────────┐
                    │  Internet Gateway  │
                    └────────────────────┘
```

## Standard Unity Network Patterns

### Web Application Pattern

```hcl
module "unity_vpc" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/vpc?ref=v1.0.0"

  vpc_cidr           = "10.0.0.0/16"
  name_prefix        = "unity-web-app"
  availability_zones = ["us-west-2a", "us-west-2b"]
  
  # Standard web app configuration
  enable_nat_gateway = true
  enable_s3_endpoint = true
}

# Use with other Unity modules
module "unity_alb_sg" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/iam?ref=v1.0.0"
  
  role_name = "unity-alb-role"
  role_type = "service"
  vpc_id    = module.unity_vpc.vpc_id
}
```

### Data Processing Pattern

```hcl
module "unity_vpc" {
  source = "github.com/unity-sds/unity-terraform-modules//modules/vpc?ref=v1.0.0"

  vpc_cidr           = "10.0.0.0/16"
  name_prefix        = "unity-data-proc"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  # Data processing optimizations
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
  enable_flow_log         = true
}
```

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
| aws_vpc.main | resource |
| aws_internet_gateway.main | resource |
| aws_subnet.public | resource |
| aws_subnet.private | resource |
| aws_eip.nat | resource |
| aws_nat_gateway.main | resource |
| aws_route_table.public | resource |
| aws_route_table.private | resource |
| aws_route.public_internet_gateway | resource |
| aws_route.private_nat_gateway | resource |
| aws_route_table_association.public | resource |
| aws_route_table_association.private | resource |
| aws_vpn_gateway.main | resource |
| aws_flow_log.vpc | resource |
| aws_vpc_endpoint.s3 | resource |
| aws_vpc_endpoint.dynamodb | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr | CIDR block for the VPC | `string` | n/a | yes |
| name_prefix | Name prefix for all resources | `string` | n/a | yes |
| availability_zones | List of availability zones | `list(string)` | n/a | yes |
| environment | Environment name | `string` | `"dev"` | no |
| project | Project name | `string` | `"unity"` | no |
| enable_dns_hostnames | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Enable DNS support in the VPC | `bool` | `true` | no |
| enable_nat_gateway | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| create_igw | Create Internet Gateway | `bool` | `true` | no |
| map_public_ip_on_launch | Map public IP on launch for public subnets | `bool` | `true` | no |
| enable_vpn_gateway | Enable VPN Gateway | `bool` | `false` | no |
| enable_flow_log | Enable VPC Flow Logs | `bool` | `false` | no |
| enable_s3_endpoint | Enable S3 VPC Endpoint | `bool` | `false` | no |
| enable_dynamodb_endpoint | Enable DynamoDB VPC Endpoint | `bool` | `false` | no |
| single_nat_gateway | Use a single NAT Gateway for all private subnets | `bool` | `false` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| public_subnets | List of IDs of public subnets |
| private_subnets | List of IDs of private subnets |
| public_subnets_cidr_blocks | List of CIDR blocks of public subnets |
| private_subnets_cidr_blocks | List of CIDR blocks of private subnets |
| igw_id | The ID of the Internet Gateway |
| nat_ids | List of IDs of the NAT Gateways |
| nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway |
| public_route_table_ids | List of IDs of the public route tables |
| private_route_table_ids | List of IDs of the private route tables |
| vpc_endpoint_s3_id | The ID of VPC endpoint for S3 |
| vpc_endpoint_dynamodb_id | The ID of VPC endpoint for DynamoDB |

## Security Considerations

- **Private Subnets**: Application resources should be deployed in private subnets
- **NAT Gateways**: Enable NAT gateways for outbound internet access from private subnets
- **VPC Endpoints**: Use VPC endpoints to avoid data transfer costs and improve security
- **Flow Logs**: Enable VPC flow logs for network monitoring and security analysis
- **Default Security Group**: The default security group is configured with no rules

## Cost Optimization

- **Single NAT Gateway**: Use `single_nat_gateway = true` for development environments
- **VPC Endpoints**: Enable S3 and DynamoDB endpoints to reduce NAT gateway costs
- **Right-sizing**: Choose appropriate AZ count based on your availability requirements

## Best Practices

1. **CIDR Planning**: Use non-overlapping CIDR blocks for multiple VPCs
2. **Multi-AZ**: Deploy across at least 2 AZs for high availability
3. **Subnet Sizing**: Plan subnet sizes based on expected resource counts
4. **Tagging**: Use consistent tagging for cost tracking and management
5. **Flow Logs**: Enable flow logs for security monitoring
6. **VPC Endpoints**: Use endpoints for frequently accessed AWS services

## License

This module is part of the Unity Science Data System (SDS) and is licensed under the Apache License 2.0.