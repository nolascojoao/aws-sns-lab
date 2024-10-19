#!/bin/bash

set -e

# Step 3: Create a Route Table and Configure Route to IGW

# Retrieve the VPC ID automatically
vpc_id=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=LAB-VPC" \
  --query "Vpcs[0].VpcId" \
  --output text)

echo "Retrieved VPC ID: $vpc_id"

# Retrieve the Internet Gateway ID automatically
igw_id=$(aws ec2 describe-internet-gateways \
  --filters "Name=tag:Name,Values=LAB-IGW" \
  --query "InternetGateways[0].InternetGatewayId" \
  --output text)

echo "Retrieved Internet Gateway ID: $igw_id"

# Retrieve the Subnet ID automatically
subnet_id=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=public-lab-subnet" \
  --query "Subnets[0].SubnetId" \
  --output text)

echo "Retrieved Subnet ID: $subnet_id"

# Create a Route Table
route_table_id=$(aws ec2 create-route-table \
  --vpc-id "$vpc_id" \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=CLI-RouteTable}]' \
  --query 'RouteTable.RouteTableId' \
  --output text)

echo "Created Route Table: $route_table_id"

# Create a Route for Internet Access
aws ec2 create-route \
  --route-table-id "$route_table_id" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "$igw_id"

echo "Created Route to IGW in Route Table: $route_table_id"

# Associate the Route Table with the Subnet
aws ec2 associate-route-table \
  --subnet-id "$subnet_id" \
  --route-table-id "$route_table_id"

echo "Associated Route Table with Subnet: $subnet_id"
