# 1. Create SQS access policy document
cat << EOF > sqs-policy.json
{
  "Version": "2012-10-17",
  "Id": "S3EventsToSQSPolicy",
  "Statement": [
    {
      "Sid": "AllowS3ToSendMessage",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${QUEUE_ARN}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:s3:::${BUCKET_NAME}"
        },
        "StringEquals": {
          "aws:SourceAccount": "${AWS_ACCOUNT_ID}"
        }
      }
    }
  ]
}
EOF
# 2. Apply policy to the queue (escaped as a JSON string inside attributes)
aws sqs set-queue-attributes \
    --queue-url $QUEUE_URL \
    --attributes Policy="$(cat sqs-policy.json)"