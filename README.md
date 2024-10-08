# AWS SNS Image Notification Lab

<div align="center">
  <img src="screenshot/Architecture.png" width=""/>
</div>

## Overview
Set up an S3 bucket with event notifications to trigger email alerts via SNS for new image uploads.

---
⚠️ **Attention:**
- All the tasks will be completed via the command line using AWS CLI. Ensure you have the necessary permissions. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Charges may apply for completing this lab. [AWS Pricing](https://aws.amazon.com/pricing/)
---

## Step 1: Create VPC and Subnet
#### 1.1. Create a VPC:
```bash
aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=LAB-VPC}]'
```
#### 1.2. Create a Subnet:
```bash
aws ec2 create-subnet \
  --vpc-id <vpc-id> \
  --cidr-block 10.0.1.0/24 \
  --availability-zone <region-az> \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-lab-subnet}]'
```

---

## Step 2: Create and Associate an Internet Gateway (IGW)
#### 2.1. Create an Internet Gateway:
```bash
aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=LAB-IGW}]'
```
#### 2.2. Attach the Internet Gateway to the VPC:
```bash
aws ec2 attach-internet-gateway \
  --vpc-id <vpc-id> \
  --internet-gateway-id <igw-id>
```

---

## Step 3: Create a Route Table and Configure Route to IGW
#### 3.1. Create a Route Table:
```bash
aws ec2 create-route-table \
  --vpc-id <vpc-id> \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=CLI-RouteTable}]'
```
#### 3.2. Create a Route for Internet Access:
```bash
aws ec2 create-route \
  --route-table-id <route-table-id> \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id <igw-id>
```
#### 3.3. Associate the Route Table with the Subnet:
```bash
aws ec2 associate-route-table \
  --subnet-id <subnet-id> \
  --route-table-id <route-table-id>
```

---

## Step 4: Create and Configure the EC2 Instance (CLI Host)
#### 4.1. Create a Security Group for the EC2 instance:
```bash
aws ec2 create-security-group \
  --group-name CLI-SecurityGroup \
  --description "Security group for CLI Host" \
  --vpc-id <vpc-id>
```
#### 4.2. Authorize SSH and HTTP traffic:
- Allow SSH (port 22):
```bash
aws ec2 authorize-security-group-ingress \
  --group-id <group-id> \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```
- Allow HTTP (port 80):
```bash
aws ec2 authorize-security-group-ingress \
  --group-id <group-id> \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```
#### 4.3. Launch the EC2 instance:
- **AMI Suggestion:** `ami-0ebfd941bbafe70c6`. [Find an AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html)
```bash
aws ec2 run-instances \
  --image-id <ami-id> \
  --instance-type t2.micro \
  --key-name <your-key-pair> \
  --security-group-ids <group-id> \
  --subnet-id <subnet-id> \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=CLI-Host}]'
```
- ⚠️ To create a key-pair:
```bash
aws ec2 create-key-pair \
  --key-name <key-pair-name> \
  --query 'KeyMaterial' \
  --output text > <key-pair-name>.pem
```
#### 4.4. Connect to the EC2 instance using ssh:
```bash
ssh -i <ssh-public-key> ec2-user@<public-ip>
```
- ⚠️ To retrieve the public IP:
```bash
aws ec2 describe-instances \
  --instance-ids <instance-id> \
  --query "Reservations[*].Instances[*].PublicIpAddress" --output text
```

---

## Step 5: Create the S3 Bucket
#### 5.1. Create an S3 Bucket:
```bash
aws s3api create-bucket --bucket <bucket-name> 
```
#### 5.2. Set public permissions for the S3 Bucket:
```bash
aws s3api put-public-access-block \
  --bucket <bucket-name> \
  --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false
```

---

## Step 6: Set Up SNS Topic
#### 6.1. Create an SNS Topic:
```bash
aws sns create-topic --name s3NotificationTopic
```
#### 6.2. Subscribe an email to the SNS Topic:
```bash
aws sns subscribe \
  --topic-arn <topic-arn> \
  --protocol email \
  --notification-endpoint <your-email>
```
#### 6.3. Confirm the email subscription:
- Check your inbox and confirm the subscription using the link provided in the email

---

## Step 7: Configure S3 Notification to Trigger SNS
#### 7.1. Set up event notifications for the S3 Bucket for image file types:
```bash
aws s3api put-bucket-notification-configuration --bucket <bucket-name> \
--notification-configuration '{
    "TopicConfigurations": [
        {
            "TopicArn": "<topic-arn>",
            "Events": ["s3:ObjectCreated:*"],
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
```

---

## Step 8: Verify the Setup
#### 8.1. Upload an Image File to the S3 Bucket:
```bash
aws s3 cp <path-to-your-image-file> s3://<bucket-name>/
```
#### 8.2. Check Your Email for Notification:
- After successfully uploading an image file you should receive an email notification from the SNS topic.
