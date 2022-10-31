import json
import boto3

from collections import defaultdict

def analysis_handler(event, context):
    # Filename passed in as query string parameter (ex. fileName=tweets.txt)

    # PULL DATA FROM RAW DATA BUCKET, RUN ANALYSIS    
    s3 = boto3.client("s3")
    bucket = "rit-cloud-team-2-raw-data-bucket-test"

    file_name = event['queryStringParameters']['fileName']
    name = event['queryStringParameters']['name']
    postDeath = "True" if event['queryStringParameters']['postDeath'] == "True" else "False"
    text = s3.get_object(Bucket = bucket, Key = file_name)
    tweets = text['Body'].read().decode('utf-8').split('\n')
    # Split text file up into an array so each individual tweet is analyzed
    # Each line in text file is 1 tweet

    # [ANALYSIS CODE GOES HERE]
    # Lists to hold sentiment labels and sentiment scores
    sentiments = []
    sentiment_counts = defaultdict(int)
    pos_scores, pos_aggr_score = [], 0
    neg_scores, neg_aggr_score = [], 0
    neutral_scores, neutral_aggr_score = [], 0
    mixed_scores, mixed_aggr_score = [], 0

    # Perform sentiment analysis on each tweet
    comprehend = boto3.client("comprehend")
    for tweet in tweets:
        tweet = tweet.strip()
        if tweet == "":
            continue
        res = comprehend.detect_sentiment(Text = tweet, LanguageCode='en')

        sentiment = res['Sentiment']
        sentiments.append(sentiment)
        sentiment_counts[sentiment] += 1
        for key, val in res['SentimentScore'].items():
            if key == "Positive":
                pos_scores.append(val)
                pos_aggr_score += float(val)
            if key == "Negative":
                neg_scores.append(val)
                neg_aggr_score += float(val)
            if key == "Neutral":
                neutral_scores.append(val)
                neutral_aggr_score += float(val)
            if key == "Mixed":
                mixed_scores.append(val)
                mixed_aggr_score += float(val)

    num_of_tweets = len(tweets)
    pos_aggr_score /= num_of_tweets
    neg_aggr_score /= num_of_tweets
    mixed_aggr_score /= num_of_tweets
    neutral_aggr_score /= num_of_tweets

    body = {
            'Name': name,
            'PostDeath': postDeath,
            'PositiveScore': str(pos_aggr_score),
            'PositiveFrequency': sentiment_counts['POSITIVE'],
            'NegativeScore': str(neg_aggr_score),
            'NegativeFrequency': sentiment_counts['NEGATIVE'],
            'NeutralScore': str(neutral_aggr_score),
            'NeutralFrequency': sentiment_counts['NEUTRAL'],
            'MixedScore': str(mixed_aggr_score),
            'MixedFrequency': sentiment_counts['MIXED']
        }

    # STORE RESULTS IN DB, THEN RETURN RESULTS
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table('CachedPeople')
    # Aggregated scores are string because DynamoDB does not support float.
    response = table.put_item(
        Item=body
    )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }