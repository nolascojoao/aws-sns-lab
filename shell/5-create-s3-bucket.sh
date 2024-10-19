#!/bin/bash

set -e

# Step 5: Create the S3 Bucket
bucket_name="bucket-1910241820"  # Replace with your bucket name

# Create an S3 Bucket
aws s3api create-bucket --bucket "$bucket_name" 

echo "Created S3 Bucket: $bucket_name"

# Set public permissions for the S3 Bucket
aws s3api put-public-access-block \
  --bucket "$bucket_name" \
  --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false

echo "Set public permissions for S3 Bucket: $bucket_name"

# Set bucket policy
aws s3api put-bucket-policy --bucket "$bucket_name" --policy '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'"$bucket_name"'/*"
        }
    ]
}'

echo "Set bucket policy for S3 Bucket: $bucket_name"
