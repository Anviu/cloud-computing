import json
import boto3
from datetime import datetime

class CORSUtil:


    def __init__(self, refresh_freq):
        self.refresh = refresh_freq
        self.last_invokation = datetime.min
        self.cors = []

    def get_cors(self):
        delta = datetime.now() - self.last_invokation
        if delta.total_seconds() > self.refresh:
            l_client = boto3.client("lambda")
            response = l_client.invoke(
                FunctionName="CORSProvider",
                InvocationType="RequestResponse",
                Payload=json.dumps({})
            )

            cors_js = json.loads(response["Payload"].read().decode("utf-8"))
            self.cors = cors_js["cors"]
            self.last_invokation = datetime.now()
        return self.cors