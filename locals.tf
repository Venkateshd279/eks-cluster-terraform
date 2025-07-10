# Common local values for resource naming and tagging
locals {
  common_tags = {
    Environment = "production"
    Project     = var.cluster_name
    ManagedBy   = "terraform"
  }

  eks_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
