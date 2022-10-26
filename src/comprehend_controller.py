import boto3
import json
# Lambda function to handle comprehend sentiment analysis

def lambda_handler(event, context):
    # Grab raw data for analysis
    s3 = boto3.client("s3")
    bucket = "name of bucket"

    key = "name of text file"
    text = s3.get_object(Bucket = bucket, Key = key)
    review = str(text['Body'].read())

    # Perform sentiment analysis on text from bucket
    comprehend = boto3.client("comprehend")
    response = comprehend.detect_sentiment(Text = review, LanguageCode = "en")
    print(response)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(response)
    }

