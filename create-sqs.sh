#!/bin/bash

# 1. Create queue and capture URL
export QUEUE_URL=$(aws sqs create-queue \
    --queue-name $QUEUE_NAME \
    --query "QueueUrl" \
    --output text)

# 2. Get Queue ARN
export QUEUE_ARN=$(aws sqs get-queue-attributes \
    --queue-url $QUEUE_URL \
    --attribute-names QueueArn \
    --query "Attributes.QueueArn" \
    --output text)

echo "QUEUE_URL: $QUEUE_URL"
echo "QUEUE_ARN: $QUEUE_ARN"

# mauanlly export the echo output because running this file does not make env. So we need to make it manually in terminal.