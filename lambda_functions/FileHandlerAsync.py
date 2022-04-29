import json
import boto3
import base64
import time
from package.fpdf import FPDF
from package.util import ResponseUtil
from package.util import PDFUtil

def handle(event, context):
    body = event["body"]
    bodyjson = json.loads(str(body))
    response = detect_text(bodyjson.get("bucket"), bodyjson.get("key"))
    pdf = PDFUtil.gen_pdf(response)   
    key = PDFUtil.upload_to_s3(pdf) 

    return ResponseUtil.success({"message": key})


def detect_text(bucket, key):

    textract = boto3.client('textract')
    response = textract.start_document_text_detection(
		DocumentLocation={
			"S3Object": {
				"Bucket": bucket,
				"Name": key
			}
		}
	)

    time.sleep(1)
    jobid = response['JobId']
    response = textract.get_document_text_detection(JobId=jobid)
    status = response["JobStatus"]
    i = 0
    while(status == "IN_PROGRESS"):
        time.sleep(1)
        response = textract.get_document_text_detection(JobId=jobid)
        status = response["JobStatus"]
        i = i + 1
        if(i == 10):
            break

    return response
