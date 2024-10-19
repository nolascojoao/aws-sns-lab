#!/bin/bash

set -e

# Step 8: Verify the Setup
# Retrieve the S3 bucket name automatically (assuming only one bucket exists)
bucket_name=$(aws s3api list-buckets --query "Buckets[0].Name" --output text)

# Check if a bucket was found
if [ -z "$bucket_name" ]; then
  echo "No S3 bucket found. Exiting..."
  exit 1
fi

# Upload an Image File to the S3 Bucket
curl -o your-image.jpg https://d2908q01vomqb2.cloudfront.net/d435a6cdd786300dff204ee7c2ef942d3e9034e2/2024/09/16/IT-1-300x200.jpg

# Upload the image to the S3 bucket
aws s3 cp your-image.jpg s3://"$bucket_name"/images/

echo "Uploaded image to S3 Bucket: $bucket_name"

echo "Check your email for notification from SNS."
