# twitter_controller.py
# Accesses Twitter via Tweepy API

import tweepy
from dotenv import dotenv_values
# Raavi's Twitter Developer Credentials

userConfig = dotenv_values(".env")
API = tweepy.Client(userConfig['BEARER_TOKEN'])

xxxtentacion = API.get_user(username='xxxtentacion')[0]['id']

x_tweets = API.get_users_tweets(xxxtentacion)[0]

# Paginates tweets up to end_time parameter, end_time = death date
tweets_pages = tweepy.Paginator(
    API.get_users_tweets, id=xxxtentacion, limit=5, end_time='2018-06-18T15:56:00-04:00')

for page in tweets_pages:
    print(page.data)
