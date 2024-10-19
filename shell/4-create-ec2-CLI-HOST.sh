#!/bin/bash

set -e

# Retrieve the VPC ID automatically
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=LAB-VPC" --query "Vpcs[0].VpcId" --output text)
echo "Retrieved VPC ID: $VPC_ID"

# Create a security group
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
  --group-name CLI-SecurityGroup \
  --description "Security group for CLI Host" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" --output text)

echo "Created security group with ID: $SECURITY_GROUP_ID"

# Get the public IP address
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

# Authorize SSH (port 22) from your public IP
aws ec2 authorize-security-group-ingress \
  --group-id "$SECURITY_GROUP_ID" \
  --protocol tcp \
  --port 22 \
  --cidr "$PUBLIC_IP/32"

echo "Authorized SSH access from IP: $PUBLIC_IP"

# Create a new key pair
KEY_PAIR_NAME="your-key-pair-name"  # Change this to your desired key pair name
KEY_FILE="${KEY_PAIR_NAME}.pem"

aws ec2 create-key-pair \
  --key-name "$KEY_PAIR_NAME" \
  --query 'KeyMaterial' \
  --output text > "$KEY_FILE"

# Set permissions for the key file
chmod 400 "$KEY_FILE"

echo "Created key pair: $KEY_PAIR_NAME and saved to $KEY_FILE"

# Allow HTTP (port 80)
aws ec2 authorize-security-group-ingress \
  --group-id "$SECURITY_GROUP_ID" \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

echo "Authorized HTTP access on port 80."

# Retrieve the Subnet ID automatically
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=public-lab-subnet" --query "Subnets[0].SubnetId" --output text)
echo "Retrieved Subnet ID: $SUBNET_ID"

# Use the original AMI ID
AMI_ID="ami-0ebfd941bbafe70c6"  # Your original AMI ID

# Launch the EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t2.micro \
  --key-name "$KEY_PAIR_NAME" \
  --security-group-ids "$SECURITY_GROUP_ID" \
  --subnet-id "$SUBNET_ID" \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=CLI-Host}]' \
  --query "Instances[0].InstanceId" --output text)

echo "Launched EC2 instance with ID: $INSTANCE_ID"
