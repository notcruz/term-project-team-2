import json
import boto3

from collections import defaultdict
RAW_DATA_TABLE = "RawDataTable"
RESULTS_DATA_TABLE = "CachedPeople"

def analysis_handler(event, context):
    # Name passed in as query string parameter 
    # (ex. name=QueenElizabeth)

    # PULL DATA FROM RAW DATA BUCKET, RUN ANALYSIS
    dynamodb = boto3.resource("dynamodb")
    raw_table = dynamodb.Table(RAW_DATA_TABLE)

    # s3 = boto3.client("s3")
    # bucket = "rit-cloud-team-2-raw-data-bucket-test"
    # file_name = event['queryStringParameters']['fileName']
    # text = s3.get_object(Bucket = bucket, Key = file_name)
    # pre_tweets = text['Body'].read().decode('utf-8').split('\n')
    name = event['queryStringParameters']['name']
    
    # From Dynamo
    inp_response = raw_table.get_item(
        TableName=RAW_DATA_TABLE,
        Key={
            'name': name
        }
    )

    # Split dynamodb JSON into an array of tweets to analyze
    pre_tweets = _extract_tweets(inp_response['Item']['pre'])
    post_tweets = _extract_tweets(inp_response['Item']['post'])

    # Perform sentiment analysis on each tweet
    comprehend = boto3.client("comprehend")
    pre_sentiment_counts, pre_positive, pre_negative, pre_neutral, pre_mixed = _process_tweets(comprehend, pre_tweets)
    post_sentiment_counts, post_positive, post_negative, post_neutral, post_mixed = _process_tweets(comprehend, post_tweets)
    
    # Store both pre and post in the same dynamodb row
    # Aggregated scores are string because DynamoDB does not support float.
    body = {
            'Name': name,
            'PrePositiveScore': str(pre_positive),
            'PrePositiveFrequency': pre_sentiment_counts['POSITIVE'],
            'PreNegativeScore': str(pre_negative),
            'PreNegativeFrequency': pre_sentiment_counts['NEGATIVE'],
            'PreNeutralScore': str(pre_neutral),
            'PreNeutralFrequency': pre_sentiment_counts['NEUTRAL'],
            'PreMixedScore': str(pre_mixed),
            'PreMixedFrequency': pre_sentiment_counts['MIXED'],
            'PostPositiveScore': str(post_positive),
            'PostPositiveFrequency': post_sentiment_counts['POSITIVE'],
            'PostNegativeScore': str(post_negative),
            'PostNegativeFrequency': post_sentiment_counts['NEGATIVE'],
            'PostNeutralScore': str(post_neutral),
            'PostNeutralFrequency': post_sentiment_counts['NEUTRAL'],
            'PostMixedScore': str(post_mixed),
            'PostMixedFrequency': post_sentiment_counts['MIXED']
        }

    # STORE RESULTS IN DB, THEN RETURN RESULTS
    results_table = dynamodb.Table(RESULTS_DATA_TABLE)
    results_response = results_table.put_item(
        Item=body
    )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }


def _extract_tweets(input):
    """Extracts tweets from dynamodb and splits for comprehend"""
    tweets = []
    for tweet in input:
        tweets.append(tweet['text'].strip())
    return tweets


def _process_tweets(comprehend, tweets):
    """Analyzes tweets via AWS Comprehend, returns corresponding scores"""
    sentiments = []
    sentiment_counts = defaultdict(int)
    pos_scores, neg_scores, neutral_scores, mixed_scores = [], [], [], []
    pos_aggr_score, neg_aggr_score, neutral_aggr_score, mixed_aggr_score = 0, 0, 0, 0
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

    return sentiment_counts, pos_aggr_score, neg_aggr_score, mixed_aggr_score, neutral_aggr_score
