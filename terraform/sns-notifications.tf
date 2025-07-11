# SNS Topic for Jenkins Pipeline Notifications
resource "aws_sns_topic" "jenkins_notifications" {
  name         = "jenkins-pipeline-notifications"
  display_name = "Jenkins Pipeline Notifications"

  tags = {
    Environment = "production"
    Project     = "eks-sample-app"
    Purpose     = "jenkins-notifications"
  }
}

# Email subscription to SNS topic
resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.jenkins_notifications.arn
  protocol  = "email"
  endpoint  = "venkatesh.d279@gmail.com"
}

# Optional: SMS subscription (uncomment if you want SMS notifications)
# resource "aws_sns_topic_subscription" "sms_notification" {
#   topic_arn = aws_sns_topic.jenkins_notifications.arn
#   protocol  = "sms"
#   endpoint  = "+91XXXXXXXXXX"  # Replace with your phone number
# }

# SNS topic policy to allow Jenkins EC2 instance to publish
resource "aws_sns_topic_policy" "jenkins_notifications_policy" {
  arn = aws_sns_topic.jenkins_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.jenkins_role.arn
        }
        Action = [
          "sns:Publish",
          "sns:GetTopicAttributes"
        ]
        Resource = aws_sns_topic.jenkins_notifications.arn
      }
    ]
  })
}

# Update Jenkins IAM role to include SNS permissions
resource "aws_iam_role_policy_attachment" "jenkins_sns_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_sns_policy.arn
}

resource "aws_iam_policy" "jenkins_sns_policy" {
  name        = "jenkins-sns-policy"
  description = "Policy for Jenkins to send SNS notifications"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:GetTopicAttributes",
          "sns:ListTopics"
        ]
        Resource = [
          aws_sns_topic.jenkins_notifications.arn,
          "${aws_sns_topic.jenkins_notifications.arn}:*"
        ]
      }
    ]
  })
}

# Output the SNS topic ARN for use in Jenkins
output "sns_topic_arn" {
  description = "ARN of the SNS topic for Jenkins notifications"
  value       = aws_sns_topic.jenkins_notifications.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for Jenkins notifications"
  value       = aws_sns_topic.jenkins_notifications.name
}
