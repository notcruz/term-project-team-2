import requests
import json

MAX_ITERATION = 10
MAX_TWEET_COUNT = 20
API_BASE_URL = "https://api.twitter.com/1.1"
BASE_URL = "https://twitter.com/i/api/2"
DEFAULT_HEADERS = {
    "authorization": "Bearer AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA",
    "x-guest-token": ""
}
DEFAULT_QUERY_PARAMS = {
    "include_profile_interstitial_type": "1",
    "include_blocking": "1",
    "include_blocked_by": "1",
    "include_followed_by": "1",
    "include_want_retweets": "1",
    "include_mute_edge": "1",
    "include_can_dm": "1",
    "include_can_media_tag": "1",
    "include_ext_has_nft_avatar": "1",
    "skip_status": "1",
    "cards_platform": "Web-12",
    "include_cards": "1",
    "include_ext_alt_text": "true",
    "include_ext_limited_action_results": "false",
    "include_quote_count": "true",
    "include_reply_count": "1",
    "tweet_mode": "extended",
    "include_ext_collab_control": "true",
    "include_entities": "true",
    "include_user_entities": "true",
    "include_ext_media_color": "true",
    "include_ext_media_availability": "true",
    "include_ext_sensitive_media_warning": "true",
    "include_ext_trusted_friends_metadata": "true",
    "send_error_codes": "true",
    "simple_quoted_tweet": "true",
    "q": "",
    "count": "20",
    "query_source": "typed_query",
    "pc": "0",
    "spelling_corrections": "1",
    "include_ext_edit_control": "true",
    "ext": "mediaStats,highlightedLabel,hasNftAvatar,replyvotingDownvotePerspective,voiceInfo,birdwatchPivot,enrichments,superFollowMetadata,unmentionInfo,editControl,collab_control,vibe"
}


def set_twitter_token(session):
    response = session.post(f"{API_BASE_URL}/guest/activate.json")
    if response.ok:
        json = response.json()
        session.headers.update({"x-guest-token": json["guest_token"]})
    return response.ok


def get_tweets(session, count, q):
    # shallow copy for the default params
    headers = DEFAULT_QUERY_PARAMS.copy()
    result = []
    iteration_count = 0
    while count > 0:
        c = MAX_TWEET_COUNT
        headers.update({"q": q})
        headers.update({"count": c})
        response = session.get(f"{BASE_URL}/search/adaptive.json", params=headers)
        # guest token probably expired or something of that sorts, attempt to do request again
        # should probably handle this differently
        if response.status_code == 403:
            set_twitter_token(session)
            iteration_count += 1
            if iteration_count == MAX_ITERATION:
                break
        elif response.ok:
            result.append(response.json())
            count -= MAX_TWEET_COUNT
        else:
            count -= MAX_TWEET_COUNT
    return result


# POST /tweets
#   body / data = {count: int, query: str}

def lambda_handler(event, context):
    [count, query] = event.get(
        "count", MAX_TWEET_COUNT), event.get("query", None)
    if query is None or len(query) <= 0:
        return {"statusCode": 400, "body": "Provide a query with a length greater than zero."}
    session = requests.Session()
    session.headers.update(DEFAULT_HEADERS)
    if (not set_twitter_token(session)):
        return {"statusCode": 403}
    data = get_tweets(session, count, query)
    return {"statusCode": 200, "body": json.dumps({"request_count": len(data), "data": data})}
