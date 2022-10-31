import json

def analysis_handler(event, context):

    # PULL DATA FROM RAW DATA BUCKET, RUN ANALYSIS    

    # [ANALYSIS CODE GOES HERE]

    # STORE RESULTS IN DB, THEN RETURN RESULTS

    return {
        "nameScanned": "Paul Rudd",
        "data": "This is test return data lol"
    }