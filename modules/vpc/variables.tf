# Variables for Unity VPC Module

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  
  validation {
    condition     = length(var.availability_zones) >= 1
    error_message = "At least one availability zone must be specified."
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

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "create_igw" {
  description = "Create Internet Gateway"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch for public subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "amazon_side_asn" {
  description = "ASN for the Amazon side of the VPN Gateway"
  type        = number
  default     = 64512
}

variable "propagate_public_route_tables_vgw" {
  description = "Propagate public route tables to VPN Gateway"
  type        = bool
  default     = false
}

variable "propagate_private_route_tables_vgw" {
  description = "Propagate private route tables to VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_flow_log" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_iam_role_arn" {
  description = "IAM role ARN for VPC Flow Logs"
  type        = string
  default     = null
}

variable "flow_log_destination_arn" {
  description = "Destination ARN for VPC Flow Logs (CloudWatch Log Group or S3 bucket)"
  type        = string
  default     = null
}

variable "flow_log_traffic_type" {
  description = "Traffic type for VPC Flow Logs"
  type        = string
  default     = "ALL"
  
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_log_traffic_type)
    error_message = "Flow log traffic type must be one of: ACCEPT, REJECT, ALL."
  }
}

variable "enable_s3_endpoint" {
  description = "Enable S3 VPC Endpoint"
  type        = bool
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB VPC Endpoint"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Subnet configurations
variable "public_subnet_suffix" {
  description = "Suffix to append to public subnet names"
  type        = string
  default     = "public"
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnet names"
  type        = string
  default     = "private"
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Create one NAT Gateway per AZ (high availability)"
  type        = bool
  default     = true
}

# Security
variable "manage_default_security_group" {
  description = "Manage the default security group"
  type        = bool
  default     = true
}

variable "default_security_group_name" {
  description = "Name for the default security group"
  type        = string
  default     = null
}

variable "default_security_group_ingress" {
  description = "List of ingress rules for default security group"
  type        = list(map(string))
  default     = []
}

variable "default_security_group_egress" {
  description = "List of egress rules for default security group"
  type        = list(map(string))
  default     = []
}

# DHCP Options
variable "enable_dhcp_options" {
  description = "Enable DHCP options"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Domain name for DHCP options"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "List of domain name servers for DHCP options"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

# Network ACLs
variable "manage_default_network_acl" {
  description = "Manage the default network ACL"
  type        = bool
  default     = false
}

variable "default_network_acl_name" {
  description = "Name for the default network ACL"
  type        = string
  default     = null
}

variable "public_dedicated_network_acl" {
  description = "Create dedicated network ACL for public subnets"
  type        = bool
  default     = false
}

variable "private_dedicated_network_acl" {
  description = "Create dedicated network ACL for private subnets"
  type        = bool
  default     = false
}

# VPC Endpoints additional configuration
variable "vpc_endpoints" {
  description = "Map of VPC endpoints to create"
  type = map(object({
    service         = string
    type           = string
    route_table_ids = optional(list(string))
    subnet_ids     = optional(list(string))
    security_group_ids = optional(list(string))
    policy         = optional(string)
  }))
  default = {}
}

# Custom route configurations
variable "public_route_table_tags" {
  description = "Additional tags for public route tables"
  type        = map(string)
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for private route tables"
  type        = map(string)
  default     = {}
}

# Subnet-specific tags
variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default     = {}
}