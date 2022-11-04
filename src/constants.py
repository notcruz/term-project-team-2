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