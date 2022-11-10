import json
import boto3
import random

from collections import defaultdict
RAW_DATA_TABLE = "RawDataTable"
RESULTS_DATA_TABLE = "CachedPeople"

def analysis_handler(event, context):
    # Name passed in as query string parameter
    # (ex. name=QueenElizabeth)

    # PULL DATA FROM RAW DATA BUCKET, RUN ANALYSIS
    dynamodb = boto3.resource("dynamodb")
    raw_table = dynamodb.Table(RAW_DATA_TABLE)

    if 'queryStringParameters' in event and 'name' not in event['queryStringParameters']:
        return {"statusCode": 403, "body": json.dumps({"error": f"Query string parameter (name) is missing"})}

    name = event['queryStringParameters']['name']

    # From Dynamo
    inp_response = raw_table.get_item(
        TableName=RAW_DATA_TABLE,
        Key={
            'name': name
        }
    )

    if 'Item' not in inp_response:
        return {"statusCode": 403, "body": json.dumps({"error": f"{name} does not exist in table, check spelling"})}

    if 'pre' not in inp_response['Item'] or 'post' not in inp_response['Item']:
        return {"statusCode": 403, "body": json.dumps({"error": f"Invalid tweet format"})}

    pre_tweets = inp_response['Item']['pre']
    post_tweets = inp_response['Item']['post']

    # Perform sentiment analysis on each tweet
    comprehend = boto3.client("comprehend")
    pre_sentiment_counts, pre_positive, pre_negative, pre_neutral, pre_mixed, pre_tweet_scores = _process_tweets(comprehend, pre_tweets)
    post_sentiment_counts, post_positive, post_negative, post_neutral, post_mixed, post_tweet_scores = _process_tweets(comprehend, post_tweets)

    # Grab random sample tweets and corresponding scores
    NUM_OF_SAMPLES = 5
    pre_samples = _get_samples(pre_tweet_scores, NUM_OF_SAMPLES)
    post_samples = _get_samples(post_tweet_scores, NUM_OF_SAMPLES)

    # Store both pre and post in the same dynamodb row
    # Aggregated scores are string because DynamoDB does not support float.
    body = {
            'Name': name,
            'Data': {
                'Frequency': {
                    'Pre': {
                        'PositiveFrequency': pre_sentiment_counts['POSITIVE'],
                        'NegativeFrequency': pre_sentiment_counts['NEGATIVE'],
                        'NeutralFrequency': pre_sentiment_counts['NEUTRAL'],
                        'MixedFrequency': pre_sentiment_counts['MIXED']
                    },
                    'Post': {
                        'PositiveFrequency': post_sentiment_counts['POSITIVE'],
                        'NegativeFrequency': post_sentiment_counts['NEGATIVE'],
                        'NeutralFrequency': post_sentiment_counts['NEUTRAL'],
                        'MixedFrequency': post_sentiment_counts['MIXED']
                    }
                },
                'Score': {
                    'Pre': {
                        'PositiveScore': str(pre_positive),
                        'NegativeScore': str(pre_negative),
                        'NeutralScore': str(pre_neutral),
                        'MixedScore': str(pre_mixed)
                    },
                    'Post': {
                        'PositiveScore': str(post_positive),
                        'NegativeScore': str(post_negative),
                        'NeutralScore': str(post_neutral),
                        'MixedScore': str(post_mixed)
                    }
                },
                'Samples': {
                    'Pre': {id: score for id, score in pre_samples},
                    'Post': {id: score for id, score in post_samples}
                }
            }
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


def _get_samples(tweet_scores, num_of_samples):
    return random.sample(tweet_scores.items(), num_of_samples)


def _process_tweets(comprehend, tweets):
    """Analyzes tweets via AWS Comprehend, returns corresponding scores and sample tweets"""
    sentiment_counts = defaultdict(int)
    tweet_scores = {}
    pos_aggr_score, neg_aggr_score, neutral_aggr_score, mixed_aggr_score = 0, 0, 0, 0
    for item in tweets:
        id = str(item['id'])
        tweet = item['text'].strip()
        if tweet == "":
            continue
        res = comprehend.detect_sentiment(Text = tweet, LanguageCode='en')

        sentiment = res['Sentiment']
        tweet_scores[id] = {}
        tweet_scores[id]['Sentiment'] = sentiment
        sentiment_counts[sentiment] += 1
        for key, val in res['SentimentScore'].items():
            if key == "Positive":
                tweet_scores[id]['Positive'] = str(val)
                pos_aggr_score += float(val)
            if key == "Negative":
                tweet_scores[id]['Negative'] = str(val)
                neg_aggr_score += float(val)
            if key == "Neutral":
                tweet_scores[id]['Neutral'] = str(val)
                neutral_aggr_score += float(val)
            if key == "Mixed":
                tweet_scores[id]['Mixed'] = str(val)
                mixed_aggr_score += float(val)

    num_of_tweets = len(tweets)
    pos_aggr_score /= num_of_tweets
    neg_aggr_score /= num_of_tweets
    mixed_aggr_score /= num_of_tweets
    neutral_aggr_score /= num_of_tweets

    return sentiment_counts, pos_aggr_score, neg_aggr_score, mixed_aggr_score, neutral_aggr_score, tweet_scores
