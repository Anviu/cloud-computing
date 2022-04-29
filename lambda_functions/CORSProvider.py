import json
import boto3

bucket = "cfg-bucket.example.com"

def handle(event, context):

    s3 = boto3.client("s3")
    response = s3.get_object(
        Bucket = bucket,
        Key = "cors_cfg.json",
    )
    
    cors = json.loads(response["Body"].read().decode("utf-8"))

    return cors