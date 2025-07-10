# Jenkins Server for EKS CI/CD
# This creates a Jenkins server on EC2 with all required tools

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_jenkins" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for Jenkins server
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.cluster_name}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.eks_vpc.id

  # HTTP access for Jenkins
  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access (optional)
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-jenkins-sg"
  }
}

# IAM role for Jenkins EC2 instance
resource "aws_iam_role" "jenkins_role" {
  name = "${var.cluster_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-jenkins-role"
  }
}

# IAM policy for Jenkins to access EKS and ECR
resource "aws_iam_policy" "jenkins_policy" {
  name        = "${var.cluster_name}-jenkins-policy"
  description = "IAM policy for Jenkins to access EKS and ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:ListRepositories"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:PassRole"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to Jenkins role
resource "aws_iam_role_policy_attachment" "jenkins_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}

# Instance profile for Jenkins
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.cluster_name}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

# User data script for Jenkins setup
locals {
  jenkins_user_data = base64encode(templatefile("${path.module}/cicd/jenkins/jenkins-setup.sh", {
    cluster_name = var.cluster_name
    region       = var.aws_region
  }))
}

# Jenkins EC2 instance
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.amazon_linux_jenkins.id
  instance_type          = "t3.medium"  # Enough for Jenkins with Docker
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.public_subnets[0].id
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  associate_public_ip_address = true

  user_data = local.jenkins_user_data

  root_block_device {
    volume_type = "gp3"
    volume_size = 30  # 30GB for Jenkins data
    encrypted   = true
  }

  tags = {
    Name = "${var.cluster_name}-jenkins-server"
    Type = "CI/CD"
    Environment = "production"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Output Jenkins information
output "jenkins_public_ip" {
  description = "Public IP address of Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS name of Jenkins server"
  value       = aws_instance.jenkins_server.public_dns
}

output "jenkins_url" {
  description = "Jenkins web interface URL"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins server"
  value       = "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.jenkins_server.public_ip}"
}
