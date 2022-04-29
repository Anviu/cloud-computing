import json

def success(body, status = 200, allow_origin = "*", base64Enc = False):
     return __createResponse(body, status=status, allow_origin= allow_origin, base64Enc=base64Enc)

def failure(body, status = 404, allow_origin = "*", base64Enc = False):
     return __createResponse(body, status=status, allow_origin= allow_origin, base64Enc=base64Enc)

def __createResponse(body, status, allow_origin, base64Enc):
    return {
                "isBase64Encoded": base64Enc,
                "statusCode": status,
                "headers": {
                    "Access-Control-Allow-Origin" : allow_origin,
                    'Content-Type': 'application/json',
                },
                "body": json.dumps(body)
            }