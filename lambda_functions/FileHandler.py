import json
import hashlib
import base64
import boto3
from package.fpdf import FPDF
from package.util import ResponseUtil
from package.util import PDFUtil

def handle(event, context):
    body = event["body"]
    bodyjson = json.loads(body)
    if "data" in bodyjson.keys():
        input_data = bodyjson.get("data")
        data_type = bodyjson.get("type")
        input_data = input_data.replace(f'data:{data_type};base64,','')

        imageBytes = bytearray(base64.b64decode(input_data))
        
        response = detect_text(imageBytes)
        pdf = PDFUtil.gen_pdf(response)
        key = PDFUtil.upload_to_s3(pdf)

        return ResponseUtil.success({"message": key})

def detect_text(imageBytes):
    textract = boto3.client('textract')
    response = textract.detect_document_text(Document={'Bytes': imageBytes})
    return response


