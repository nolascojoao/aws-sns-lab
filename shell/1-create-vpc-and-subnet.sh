#!/bin/bash

set -e

# Step 1: Create VPC and Subnet
# Create a VPC
vpc_id=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=LAB-VPC}]' \
  --query 'Vpc.VpcId' \
  --output text)

echo "Created VPC: $vpc_id"

# Create a Subnet
subnet_id=$(aws ec2 create-subnet \
  --vpc-id "$vpc_id" \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-lab-subnet}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Created Subnet: $subnet_id"
