import json
import boto3

RESULTS_DATA_TABLE = "CachedPeople"

def check_data_handler(event, context):
    
    dynamodb = boto3.resource("dynamodb")
    results_table = dynamodb.Table(RESULTS_DATA_TABLE)
    
    if 'name' not in event:
        return {"statusCode": 400, "body": json.dumps({"error": f"Query string parameter (name) is missing"})}

    death = None if 'death' not in event else event["death"]
    
    name = event['name']

    response = results_table.get_item(
        TableName=RESULTS_DATA_TABLE,
        Key={
            'Name': name.replace(" ","")
        }
    )

    if 'Item' not in response:
        return {
            "name": name,
            "death": death,
            "data": None
        }

    return {
        "name": name,
        "death": death,
        "data": response["Item"]
    }