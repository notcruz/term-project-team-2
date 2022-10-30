import json
import boto3

def check_data_handler(event, context):
    
    name = event['name'].lower()
    
    s3 = boto3.resource("s3")
    cacheBucket = s3.Bucket('rit-cloud-team-2-cached-data-bucket')

    if cacheBucket is None or not hasattr(cacheBucket, 'objects'):
        return {
            "name" : name,
            "data": None
        }
    
    for object in cacheBucket.objects.all():
        contents = json.loads(object.get()['Body'].read().decode('utf-8'))

        for person in contents['cachedNames']:
            if person['name'].lower() == name.lower():
                return person

    return {
        "name": name,
        "data": None
    }