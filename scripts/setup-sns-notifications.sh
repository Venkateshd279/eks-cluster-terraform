#!/bin/bash

# Jenkins SNS Notification Setup Script
# This script deploys SNS infrastructure for Jenkins pipeline notifications

echo "🚀 Setting up SNS notifications for Jenkins Pipeline"
echo "=================================================="

# Change to terraform directory
cd terraform

# Initialize Terraform if needed
echo "📦 Initializing Terraform..."
terraform init

# Plan the SNS resources
echo "📋 Planning SNS infrastructure..."
terraform plan -target=aws_sns_topic.jenkins_notifications \
                -target=aws_sns_topic_subscription.email_notification \
                -target=aws_sns_topic_policy.jenkins_notifications_policy \
                -target=aws_iam_policy.jenkins_sns_policy \
                -target=aws_iam_role_policy_attachment.jenkins_sns_policy

# Apply the changes
echo "🔧 Applying SNS infrastructure..."
read -p "Do you want to apply these changes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply -target=aws_sns_topic.jenkins_notifications \
                    -target=aws_sns_topic_subscription.email_notification \
                    -target=aws_sns_topic_policy.jenkins_notifications_policy \
                    -target=aws_iam_policy.jenkins_sns_policy \
                    -target=aws_iam_role_policy_attachment.jenkins_sns_policy
    
    echo "✅ SNS infrastructure deployed successfully!"
    
    # Get the SNS topic ARN
    SNS_TOPIC_ARN=$(terraform output -raw sns_topic_arn)
    echo "📋 SNS Topic ARN: $SNS_TOPIC_ARN"
    
    # Test SNS topic
    echo "🧪 Testing SNS topic..."
    aws sns publish \
        --topic-arn "$SNS_TOPIC_ARN" \
        --subject "🧪 Jenkins SNS Setup Test" \
        --message "This is a test message to confirm SNS topic is working correctly. If you receive this, your Jenkins pipeline notifications are ready!" \
        --region ap-south-1
    
    echo "✅ Test message sent!"
    echo ""
    echo "📧 Next steps:"
    echo "1. Check your email (venkatesh.d279@gmail.com) for subscription confirmation"
    echo "2. Click 'Confirm subscription' in the email"
    echo "3. Check for the test message after confirming subscription"
    echo "4. Your Jenkins pipeline will now send SNS notifications on failure"
    echo ""
    echo "🎉 SNS notifications are now configured!"
else
    echo "❌ Deployment cancelled"
fi
