import json
from urllib import response
import boto3
import time

client = boto3.client('stepfunctions')

def main_lambda_handler(event, context):

    machines = client.list_state_machines()['stateMachines'] 
    
    for sfn in machines:
        if sfn['name'] == 'main-state-machine':
            sfn_arn = sfn['stateMachineArn']
        
    execution = client.start_execution(
        stateMachineArn = sfn_arn
    )

    response = client.describe_execution(
        executionArn = execution['executionArn']
    )

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
            raise Exception("Execution Failed: " + response)
        else: 
            print("Finished")
            break

    return {
        'statusCode' : 200,
        'body' : json.dumps(response['output']) 
    }