import json

def collection_lambda_handler(event, context):

    name = event['name']

    # RUN COLLECTION HERE

    # example of what data might look like
    final = {
        'name': name,
        'data': "tweet Data Goes Here"
    }

    # STORE IN RAW DATA BUCKET

    return True