#!/bin/bash

set -e

# Step 6: Set Up SNS Topic
# Create an SNS Topic
sns_topic_arn=$(aws sns create-topic --name s3NotificationTopic --query 'TopicArn' --output text)

echo "Created SNS Topic: $sns_topic_arn"

# Subscribe an email to the SNS Topic
your_email="youremail@example.com"  # Replace with your email
aws sns subscribe --topic-arn "$sns_topic_arn" --protocol email --notification-endpoint "$your_email"

echo "Subscribed $your_email to SNS Topic: $sns_topic_arn"

# Confirm the email subscription (manual step)
echo "Please confirm the email subscription sent to $your_email."
