#!/bin/bash

set -e

# Step 2: Create and Associate an Internet Gateway (IGW)
# Retrieve the VPC ID automatically
vpc_id=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=LAB-VPC" \
  --query "Vpcs[0].VpcId" \
  --output text)

echo "Retrieved VPC ID: $vpc_id"

# Create an Internet Gateway
igw_id=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=LAB-IGW}]' \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

echo "Created Internet Gateway: $igw_id"

# Attach the Internet Gateway to the VPC
aws ec2 attach-internet-gateway \
  --vpc-id "$vpc_id" \
  --internet-gateway-id "$igw_id"

echo "Attached Internet Gateway to VPC: $vpc_id"
