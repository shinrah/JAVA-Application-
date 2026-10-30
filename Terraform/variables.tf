
# AWS Region
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-southeast-2"
}

# Existing VPC ID
variable "vpc_id" {
  description = "Existing AWS VPC ID"
  type        = string
}

# Existing Subnet ID
variable "subnet_id" {
  description = "Existing AWS Subnet ID"
  type        = string
}

# Existing Security Group ID
variable "security_group_id" {
  description = "Existing AWS Security Group ID"
  type        = string
}

# EC2 Instance Type
variable "instance_type" {
  description = "SonarQube EC2 instance type"
  type        = string
  default     = "t3.large"
}

# EC2 Disk Size
variable "disk_size" {
  description = "SonarQube EC2 root volume size in GB"
  type        = number
  default     = 30
}

# EC2 Key Pair
variable "key_pair_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

# Environment
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
