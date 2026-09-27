#!/bin/bash

# 1. Create index.py
cat << 'EOF' > index.py
import json
import os
import boto3
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')
sns_client = boto3.client('sns')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event)}")
    
    for record in event.get('Records', []):
        try:
            body = json.loads(record['body'])
            bucket = body['bucket']
            key = body['key']
            
            # Retrieve S3 object metadata
            s3_response = s3_client.head_object(Bucket=bucket, Key=key)
            
            file_name = key
            size_bytes = s3_response.get('ContentLength', 0)
            content_type = s3_response.get('ContentType', 'Unknown')
            last_modified = str(s3_response.get('LastModified'))
            etag = s3_response.get('ETag', '').strip('"')
            storage_class = s3_response.get('StorageClass', 'STANDARD')
            
            message_body = (
                f"File Upload Details:\n"
                f"---------------------\n"
                f"File Name:     {file_name}\n"
                f"Bucket:        {bucket}\n"
                f"Size:          {size_bytes} bytes\n"
                f"Content Type:  {content_type}\n"
                f"Last Modified: {last_modified}\n"
                f"ETag:          {etag}\n"
                f"Storage Class: {storage_class}\n"
            )
            
            # Publish to SNS
            sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject=f"New S3 Upload: {file_name}",
                Message=message_body
            )
            print(f"Successfully processed {key} and published to SNS.")
            
        except ClientError as e:
            print(f"AWS ClientError processing record: {e.response['Error']['Message']}")
            raise e
        except Exception as e:
            print(f"Error processing record: {str(e)}")
            raise e

    return {"statusCode": 200, "body": "Processed"}
EOF

# 2. Package into deployment zip
zip function.zip index.py

# 3. Create Lambda Function
aws lambda create-function \
    --function-name $FUNCTION_NAME \
    --runtime python3.12 \
    --role $ROLE_ARN \
    --handler index.lambda_handler \
    --zip-file fileb://function.zip \
    --timeout 30 \
    --environment "Variables={SNS_TOPIC_ARN=${TOPIC_ARN}}"

export FUNCTION_ARN=$(aws lambda get-function --function-name $FUNCTION_NAME --query "Configuration.FunctionArn" --output text)


# 4. Connect SQS -> Lambda (Event Source Mapping)
aws lambda create-event-source-mapping \
    --function-name $FUNCTION_NAME \
    --event-source-arn $QUEUE_ARN \
    --batch-size 1 \
    --enabled