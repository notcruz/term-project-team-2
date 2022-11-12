import json
import boto3

def check_data_handler(event, context):
    
    # UPDATE THIS SO THAT IT CHECKS DYNAMODB INSTEAD OF DATA CACHE

    name = event['name'].lower()
    
    dynamodb = boto3.resource("s3")
    table = dynamodb.Bucket('CachedPeople')
    
    response = table.get_item(
        Key={
            'Name': 'string'
        },
        ConsistentRead=True|False,
        ProjectionExpression='Name'
    )

    return {
        "name": name,
        "data": None
    }