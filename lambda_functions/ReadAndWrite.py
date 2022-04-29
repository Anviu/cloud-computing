import json
from package.util import ResponseUtil

def readwritedata(event, context):
    print(event)
    value = {}
    body = event["body"]
    if body:
        bodyjson = json.loads(body)
        if "data" in bodyjson.keys():
            input_data = bodyjson.get("data")
            print(input_data)
            response_data = input_data.upper()

            value = ResponseUtil.success({"message": response_data,})
        else:
            value = ResponseUtil.failure({"message": "No data",})
    else:
        value = ResponseUtil.failure({"message": "No body send",})
    return value
    

