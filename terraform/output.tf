# Output.tf
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_name" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = aws_eks_node_group.eks_nodes.arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "vpc_id" {
  description = "ID of the VPC where the cluster security group is"
  value       = aws_vpc.eks_vpc.id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnets[*].id
}

# Web Server Outputs
output "web_server_1_public_ip" {
  description = "Public IP of Web Server 1"
  value       = aws_instance.web_server_1.public_ip
}

output "web_server_2_public_ip" {
  description = "Public IP of Web Server 2"
  value       = aws_instance.web_server_2.public_ip
}

output "web_server_1_private_ip" {
  description = "Private IP of Web Server 1"
  value       = aws_instance.web_server_1.private_ip
}

output "web_server_2_private_ip" {
  description = "Private IP of Web Server 2"
  value       = aws_instance.web_server_2.private_ip
}

# App Server Outputs
output "app_server_1_private_ip" {
  description = "Private IP of App Server 1"
  value       = aws_instance.app_server_1.private_ip
}

output "app_server_2_private_ip" {
  description = "Private IP of App Server 2"
  value       = aws_instance.app_server_2.private_ip
}

# Load Balancer Output
output "web_alb_dns_name" {
  description = "DNS name of the Web Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

output "web_alb_zone_id" {
  description = "Zone ID of the Web Application Load Balancer"
  value       = aws_lb.web_alb.zone_id
}

output "key_pair_name" {
  description = "Name of the EC2 Key Pair being used"
  value       = data.aws_key_pair.existing_key_pair.key_name
}

output "region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

# Jenkins Server Outputs
output "jenkins_public_ip" {
  description = "Public IP address of Jenkins server"
  value       = aws_eip.jenkins_eip.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS name of Jenkins server"
  value       = aws_instance.jenkins_server.public_dns
}

output "jenkins_url" {
  description = "Jenkins web interface URL"
  value       = "http://${aws_eip.jenkins_eip.public_ip}:8080"
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins server"
  value       = "ssh -i ${var.key_pair_name}.pem ubuntu@${aws_eip.jenkins_eip.public_ip}"
}