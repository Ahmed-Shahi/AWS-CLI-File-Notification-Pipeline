#!/bin/bash

# 1. Create S3 bucket
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $AWS_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_REGION

# (Note: if using a region other than us-east-1, add: 
# --create-bucket-configuration LocationConstraint=$AWS_REGION)

# 2. Create and upload a sample file
echo "Hello from AWS CLI Serverless Pipeline!" > sample-report.txt

aws s3 cp sample-report.txt s3://$BUCKET_NAME/sample-report.txt



# 3. Create the notification configuration payload
cat << EOF > notification.json
{
  "QueueConfigurations": [
    {
      "QueueArn": "${QUEUE_ARN}",
      "Events": [
        "s3:ObjectCreated:*"
      ]
    }
  ]
}
EOF

# 4. Apply notification configuration to the bucket
aws s3api put-bucket-notification-configuration \
    --bucket $BUCKET_NAME \
    --notification-configuration file://notification.json