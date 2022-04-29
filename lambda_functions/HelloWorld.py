import json
from package.util import CORSUtil, ResponseUtil

util = CORSUtil(5)

def hello(event, context):
    responseMessage = "Welcome to terraform - python3.9"
    print(responseMessage)
  
    return ResponseUtil.success({"message": responseMessage}, allow_origin=util.get_cors())