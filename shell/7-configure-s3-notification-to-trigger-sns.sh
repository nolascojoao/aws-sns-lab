#!/bin/bash

set -e

# Step 6: Set SNS Topic Permissions for S3
# Retrieve the S3 bucket name automatically (assuming only one bucket exists)
bucket_name=$(aws s3api list-buckets --query "Buckets[0].Name" --output text)

# Check if a bucket was found
if [ -z "$bucket_name" ]; then
  echo "No S3 bucket found. Exiting..."
  exit 1
fi

# Retrieve the SNS topic ARN automatically (assuming only one topic exists)
sns_topic_arn=$(aws sns list-topics --query "Topics[0].TopicArn" --output text)

# Check if a SNS topic was found
if [ -z "$sns_topic_arn" ]; then
  echo "No SNS topic found. Exiting..."
  exit 1
fi

# Set SNS topic permissions for S3
aws sns set-topic-attributes \
  --topic-arn "$sns_topic_arn" \
  --attribute-name Policy \
  --attribute-value '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Action": "SNS:Publish",
        "Resource": "'"$sns_topic_arn"'",
        "Condition": {
          "ArnLike": {
            "aws:SourceArn": "arn:aws:s3:::'"$bucket_name"'"
          }
        }
      }
    ]
  }'

echo "Set permissions for SNS topic: $sns_topic_arn to allow S3 to publish notifications."

# Step 7: Configure S3 Notification to Trigger SNS
# Set up event notifications for the S3 Bucket for image file types
aws s3api put-bucket-notification-configuration --bucket "$bucket_name" \
--notification-configuration '{
    "TopicConfigurations": [
      {
        "Id": "ImageUploadEventImages",
        "TopicArn": "'"$sns_topic_arn"'",
        "Events": ["s3:ObjectCreated:Put"],
        "Filter": {
          "Key": {
            "FilterRules": [
              {
                "Name": "prefix",
                "Value": "images/"
              }
            ]
          }
        }
      }
    ]
}'

echo "Configured S3 notification to trigger SNS for bucket: $bucket_name"
