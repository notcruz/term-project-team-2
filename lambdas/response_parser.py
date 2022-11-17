""" response_parser is a python file responsible for managing behavior of initializing a dynamoDB
table and writing information received from the previous AWS lambda
"""
import boto3
import json

TABLE_NAME = ""
DYNAMO = ""

KEY_SCHEMA = [{
    'AttributeName': 'name',
    'KeyType': 'S'
}]

ATTR_DEFINITIONS = [
    {
        'AttributeName': 'name',
        'AttributeType': 'S'
    },
],
PRO_THRU = {
    'ReadCapacityUnits': 5,
    'WriteCapacityUnits': 5,
}


def lambda_handler(event, context):
    # creates instnace of the aws client with dynamodb

    db_instance = boto3.resource(DYNAMO)

    table = None
    # if the table doesn't exist create it
    if db_instance.list_tables()[TABLE_NAME] is None:
        table = createDynamoDbTable(TABLE_NAME)
    else:
        # sets to existing table
        table = db_instance.Table(TABLE_NAME)
    

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }


def createDynamoDbTable(name):
    dyno = boto3.resource(DYNAMO)

    table = dyno.create_table(TableName=TABLE_NAME,
                              KeySchema=KEY_SCHEMA,
                              AttributeDefinitions=ATTR_DEFINITIONS,
                              ProvisionedThroughput=PRO_THRU)
    table.wait_until_exists()
    return table
