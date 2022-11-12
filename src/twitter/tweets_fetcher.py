import requests
import boto3
import json
from datetime import datetime, timedelta, date as d

MAX_ITERATION = 10
MAX_TWEET_COUNT = 20
MIN_FAV_COUNT = "1000"
DATE_FORMAT = "%Y-%m-%d"
TWITTER_CREATION = "2006-3-21"
API_BASE_URL = "https://api.twitter.com/1.1"
BASE_URL = "https://twitter.com/i/api/2"
DEFAULT_HEADERS = {
    "authorization": "Bearer AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA",
    "x-guest-token": ""
}
DEFAULT_QUERY_PARAMS = {
    "skip_status": "1",
    "include_quote_count": "true",
    "include_reply_count": "1",
    "simple_quoted_tweet": "true",
    "query_source": "typed_query",
    "spelling_corrections": "1",
}
RAW_DATA_TABLE = "RawDataTable"


def set_twitter_token(session):
    response = session.post(f"{API_BASE_URL}/guest/activate.json")
    if response.ok:
        json = response.json()
        session.headers.update({"x-guest-token": json["guest_token"]})
    return response.ok


def parse_tweets(json):
    tweets = json["globalObjects"]["tweets"]
    return [
        {"created_at": tweets[key]["created_at"], "id": tweets[key]["id"], "text": tweets[key]["text"], "lang": tweets[key]["lang"], "geo": tweets[key]["geo"], "user": tweets[key]["user_id"]} for key in tweets.keys()
    ]


def get_next_token(data, cursor):
    if not cursor:
        return data["timeline"]["instructions"][0]["addEntries"]["entries"][-1]["content"]["operation"]["cursor"]["value"]
    return data["timeline"]["instructions"][-1]["replaceEntry"]["entry"]["content"]["operation"]["cursor"]["value"]


def get_tweets(session, count, q):
    # shallow copy for the default params
    headers = DEFAULT_QUERY_PARAMS.copy()
    result = []
    iteration_count = 0
    cursor = None
    while count > 0:
        c = MAX_TWEET_COUNT
        headers.update({"q": q + f" min_faves:{MIN_FAV_COUNT}",
                       "count": c, "cursor": cursor})
        response = session.get(
            f"{BASE_URL}/search/adaptive.json", params=headers)
        # guest token probably expired or something of that sorts, attempt to do request again
        # should probably handle this differently
        if response.status_code == 403:
            set_twitter_token(session)
            iteration_count += 1
            if iteration_count == MAX_ITERATION:
                break
        elif response.ok:
            data = response.json()
            result += parse_tweets(data)
            cursor = get_next_token(data, cursor)
            count -= MAX_TWEET_COUNT
        else:
            count -= MAX_TWEET_COUNT
    return result


def lambda_handler(event, context):
    # Get all the required attributes from the JSON body
    [name, count, death] = event.get("name", None), event.get(
        "count", MAX_TWEET_COUNT), event.get("death", None)

    # Ensure a name is provided to the request
    if name is None or len(name) <= 0:
        return {"statusCode": 400, "body": json.dumps({"error": "Provide a person's name with a length greater than zero."})}

    # Ensure the death happened after Twitter's creation
    if death and death < TWITTER_CREATION:
        return {"statusCode": 400, "body": json.dumps({"error": "The death occurred before Twitter was created, cannot fetch tweets."})}

    # Initialize a session and attach default headers
    session = requests.Session()
    session.headers.update(DEFAULT_HEADERS)

    # Ensure a Twitter guest token was attached to the session
    if (not set_twitter_token(session)):
        return {"statusCode": 403, "body": json.dumps({"error": "Failed to set twitter token."})}

    # Intialize the current date
    current_date = d.today()

    # Define pre_death_query
    pre_death_query = None
    if not death:
        # Not death date was provided, so assume the person is alive
        # Fetch tweets from one year ago today, up to today
        since = (current_date - timedelta(days=365)).strftime(DATE_FORMAT)
        until = current_date.strftime(DATE_FORMAT)
        pre_death_query = f"{name} since:{since} until:{until}"
    else:
        # Death date was provided, so the person is dead
        # Fetch tweets from a year before their death, up to their death - 1 day
        death_date = datetime.strptime(death, DATE_FORMAT).date()
        since = (death_date - timedelta(days=365)).strftime(DATE_FORMAT)
        # One day before death. Don't allow death tweets to influence this set
        until = (death_date - timedelta(days=1)).strftime(DATE_FORMAT)
        pre_death_query = f"{name} since:{since} until:{until}"

    # Define post_death_query
    # Can only be calculated if the person has died
    post_death_query = None
    if death:
        # Death date was provided, so the person is dead
        # Fetch tweets their death date, up to a year after
        death_date = datetime.strptime(death, DATE_FORMAT).date()
        since = death_date.strftime(DATE_FORMAT)
        until = (death_date + timedelta(days=365)).strftime(DATE_FORMAT)
        post_death_query = f"{name} since:{since} until:{until}"

    # Initialize lists for tweets
    pre_death_tweets = get_tweets(session, count, pre_death_query)
    post_death_tweets = [] if post_death_query == None else get_tweets(
        session, count, post_death_query)

    body = {"name": name.replace(" ",""), "pre": pre_death_tweets, "post": post_death_tweets}

    dynamodb = boto3.resource("dynamodb")
    raw_table = dynamodb.Table(RAW_DATA_TABLE)
    response = raw_table.put_item(Item=body)

    return {"statusCode": 200, "body": json.dumps(response)}


def main():
    # include count if you want
    input_data = {"name": "Queen Elizabeth II",
                  "death": "2022-9-8", "count": 50}
    with open("../../test/lambdas/result.json", "w") as file:
        file.write(json.dumps(json.loads(
            lambda_handler(input_data, None)["body"]), indent=4))


if __name__ == "__main__":
    main()
