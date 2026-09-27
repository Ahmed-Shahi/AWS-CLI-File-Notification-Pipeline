# 1. Create SNS Topic
export TOPIC_ARN=$(aws sns create-topic \
    --name $TOPIC_NAME \
    --query "TopicArn" \
    --output text)

# 2. Subscribe your email
aws sns subscribe \
    --topic-arn $TOPIC_ARN \
    --protocol email \
    --notification-endpoint $NOTIFICATION_EMAIL