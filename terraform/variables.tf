# AWS Configuration Variables
variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "ap-south-1"
}

# EKS Cluster Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

# EC2 Key Pair Variable
variable "key_pair_name" {
  description = "Name of existing EC2 Key Pair (without .pem extension) for SSH access"
  type        = string
  default     = "python"
}

# EC2 Instance Type Variables
variable "web_server_instance_type" {
  description = "EC2 instance type for web servers in public subnets"
  type        = string
  default     = "t2.medium"
}

variable "app_server_instance_type" {
  description = "EC2 instance type for application servers in private subnets"
  type        = string
  default     = "t2.medium"
}

# Optional Public Key Variable (currently unused)
variable "public_key" {
  description = "Public key content for EC2 instances (currently not used as we use existing key pair)"
  type        = string
  default     = ""
  sensitive   = true
}
