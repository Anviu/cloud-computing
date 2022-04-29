import json
import boto3
from package.fpdf import FPDF
import base64

def upload_to_s3(pdf):
    s3_upld = boto3.client("lambda")
    response = s3_upld.invoke(
        FunctionName = "PDF_S3_Uploader",
        InvocationType = "RequestResponse",
        Payload = json.dumps({"file": base64.b64encode(pdf).decode("ascii")})
    )
    body_json = json.loads(response["Payload"].read().decode("utf-8"))
    return body_json

def gen_pdf(textract_response):
    pdf=FPDF()
    pdf.add_page()
    pdf.set_font('Courier','B',14)
    line_counter = 5
    for item in textract_response["Blocks"]:
        if item["BlockType"] == "LINE":
            pdf.write(line_counter, f"{item['Text']} \n")
     
    return pdf.output(f"image_async.pdf",'S').encode('latin-1')