#!/bin/bash

# Get your 12-digit AWS Account ID
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export AWS_REGION="ap-southeast-1"

# Define resource names
export BUCKET_NAME="file-pipeline-bucket-${AWS_ACCOUNT_ID}"
export QUEUE_NAME="file-pipeline-queue"
export TOPIC_NAME="file-pipeline-topic"
export ROLE_NAME="lambda-file-pipeline-role"
export FUNCTION_NAME="ProcessS3EventNotification"
export NOTIFICATION_EMAIL="ahmedshahi038@gmail.com" # Replace with your email!


echo 'Ahmed'