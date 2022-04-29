import boto3
import random
import string
import base64
import json
from datetime import datetime, timedelta
from package.util import ResponseUtil

supported_mime = ["application/pdf", "image/png", "image/jpeg", "image/tiff"]

def handle_img_upld(event, context):
    return handle(event, context, "img-bucket.example.com")


def handle_textract_to_s3(event, context):
    payload = event.get("file")
    payload = base64.b64decode(payload.encode("ascii"))
    s3 = boto3.client("s3")
    exp = datetime.now() + timedelta(hours=24)
    key = createRandomStr(25)
    s3.put_object(Body=payload, Bucket="pdf-bucket.example.com", Key=key, ContentType="application/pdf", Expires=exp, ACL="public-read")
    return {"key": key}


def handle(event, context, bucket):
    body = event["body"]
    bodyjson = json.loads(body)
    input_data = bodyjson.get("data")
    data_type = bodyjson.get("type")
    input_data = input_data.replace(f'data:{data_type};base64,','')
    
    try:
        imageBytes = bytearray(base64.b64decode(input_data))
    except Exception as e:
        return ResponseUtil.failure({"error": e})

    if data_type in supported_mime:
        key = createRandomStr(25)
        s3 = boto3.client("s3")
        exp = datetime.now() + timedelta(minutes=2)

        response = s3.put_object(Body=imageBytes, Bucket=bucket, Key=key, ContentType=data_type, Expires=exp)

        if(response.get("ResponseMetadata").get("HTTPStatusCode") == 200):
            return ResponseUtil.success({"key": key})
        else:
            return ResponseUtil.failure({"message": "Could not save file"})
    else: 
        return ResponseUtil.failure({"message": "${data_type} is not supported by textract! Only pdf, png, jpeg and tiff are allowed"})


def createRandomStr(size):
    return ''.join(random.choice(string.ascii_letters) for _ in range(size))