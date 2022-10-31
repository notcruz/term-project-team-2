import json
import boto3

def analysis_handler(event, context):
    # Filename passed in as query string parameter (ex. fileName=tweets.txt)

    # PULL DATA FROM RAW DATA BUCKET, RUN ANALYSIS    
    s3 = boto3.client("s3")
    bucket = "rit-cloud-team-2-raw-data-bucket-test"

    file_name = event['queryStringParameters']['fileName']
    text = s3.get_object(Bucket = bucket, Key = file_name)
    tweets = text['Body'].read().decode('utf-8').split('\n')
    # Split text file up into an array so each individual tweet is analyzed
    # Each line in text file is 1 tweet

    # [ANALYSIS CODE GOES HERE]
    # Lists to hold sentiment labels and sentiment scores
    sentiments = []
    pos_score = []
    neg_score = []
    neutral_score = []
    mixed_score = []

    # Perform sentiment analysis on each tweet
    comprehend = boto3.client("comprehend")
    for tweet in tweets:
        tweet = tweet.strip()
        if tweet == "":
            continue
        res = comprehend.detect_sentiment(Text = tweet, LanguageCode='en')

        sentiments.append(res['Sentiment'])
        for key, val in res['SentimentScore'].items():
            if key == "Positive":
                pos_score.append(val)
            if key == "Negative":
                neg_score.append(val)
            if key == "Neutral":
                neutral_score.append(val)
            if key == "Mixed":
                mixed_score.append(val)

    # STORE RESULTS IN DB, THEN RETURN RESULTS
    dynamo = boto3.client("dynamodb")
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