import json
from urllib import response
import boto3
import time
from string import Template

client = boto3.client('stepfunctions')

def main_lambda_handler(event, context):

    if "queryStringParameters" not in event:
        return {
            "statusCode": 400,
            "body": {
                "message": "No name specified :("
            }
        }

    name = event['queryStringParameters']['name']

    death = None if 'death' not in event['queryStringParameters'] else event['queryStringParameters']['death']

    machines = client.list_state_machines()['stateMachines'] 
    
    for sfn in machines:
        if sfn['name'] == 'main-step-function':
            sfn_arn = sfn['stateMachineArn']

    inp_json = Template('{"name":  "${inputName}", "death": "${deathDate}"}')
    
    print(inp_json.safe_substitute(inputName=name, deathDate=death))

    execution = client.start_execution(
        stateMachineArn = sfn_arn,
        input = json.dumps(json.loads(inp_json.substitute(inputName=name, deathDate=str(death))))
    )

    response = client.describe_execution(
        executionArn = execution['executionArn']
    )

    # Keep checking the status of the Step Function
    # Return results (contained in latest repsponse)
    while True:
        response = client.describe_execution(
            executionArn = execution['executionArn']
        )
        time.sleep(2)

        status = response['status']

        if status == 'RUNNING':
            print("Still running...")
            continue
        elif status == 'FAILED':
            print("Execution Failed: " + str(response))
            return {
                'statusCode': 500,
                "body": str(response)
            }
        else: 
            print("Finished")
            break

    return {
        'statusCode' : 200,
        'body' : response['output'] 
    }