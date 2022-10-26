import boto3
import json
# Lambda function to handle comprehend sentiment analysis

def lambda_handler(event, context):
    # Grab raw data for analysis
    s3 = boto3.client("s3")
    bucket = "comprehend-test-bucket-raw"

    # My local testing setup, I will update to make dynamic later
    key = "testrawtweets.txt"
    text = s3.get_object(Bucket = bucket, Key = key)
    review = text['Body'].read().decode('utf-8').split('\n')
    # Split text file up into an array so each individual tweet is analyzed
    # Note: empty lines such as EOF will break the program

    # Perform sentiment analysis on text from bucket
    comprehend = boto3.client("comprehend")
    response = comprehend.batch_detect_sentiment(TextList=review, LanguageCode='en')

     # Lists to hold sentiment labels and sentiment scores
    sentiments = []
    pos_score = []
    neg_score = []
    neutral_score = []
    mixed_score = []

    for res in response['ResultList']:
        sentiments.append(res['Sentiment'])
        print(res['SentimentScore'])
        print(type(res['SentimentScore']))
        for key, val in res['SentimentScore'].items():
            if key == "Positive":
                pos_score.append(val)
            if key == "Negative":
                neg_score.append(val)
            if key == "Neutral":
                neutral_score.append(val)
            if key == "Mixed":
                mixed_score.append(val)

    body = {
            "Sentiments": sentiments,
            "Positive": pos_score,
            "Negative": neg_score,
            "Neutral": neutral_score,
            "Mixed": mixed_score
        }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }
