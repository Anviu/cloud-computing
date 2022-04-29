terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "http" {}

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}


## S3 bucket for image files
resource "aws_s3_bucket" "img-bucket" {
  bucket = "img-bucket.example.com"
  force_destroy = true
}

## S3 bucket for generated PDFs
resource "aws_s3_bucket" "pdf-bucket" {
  bucket = "pdf-bucket.example.com"
  force_destroy = true
  acl = "public-read"
  cors_rule {
              allowed_headers = ["*"]
              allowed_methods = ["GET"]
              allowed_origins = ["http://static-website-bucket.example.com.s3-website.eu-central-1.amazonaws.com/"]
              expose_headers = ["ETag"]
            }
}

## S3 bucket for configurations
resource "aws_s3_bucket" "cfg-bucket" {
  bucket = "cfg-bucket.example.com"
  force_destroy = true
}

## S3 bucket for cors config
resource "aws_s3_bucket_object" "cors_cfg" {
  bucket = aws_s3_bucket.cfg-bucket.id
  key = "cors_cfg.json"
  acl = "private"
  source = local_file.cors_cfg.filename
  content_type = "application/json"
}


## S3 Bucket for static website
module "website_s3_bucket" {
  source = "./modules/aws-s3-static-website-bucket"

  bucket_name = "static-website-bucket.example.com"

  tags = {
      Name = "Static Website Bucket"
      Environment = "Terraform"
  }

  html_source = "Site/index.html"

  misc_file_data = {
    cfg_js = {
      key = "cfg.js"
      acl = "private"
      source = local_file.index_cfg.filename
      content_type = "application/javascript"
    }
  }
  
}


### Lambda functions

module "lambda_functions" {
  source = "./modules/aws-lambda"
  
  lambda_data = {
    hello_world = {
      source_filename = "HelloWorld.py" 
      output_filename = "HelloWorld.zip"
      function_name = "HelloWorld"
      handler = "HelloWorld.hello"
      timeout = 8
    }
    read_write = {
      source_filename = "ReadAndWrite.py" 
      output_filename = "ReadAndWrite.zip"
      function_name = "ReadAndWrite"
      handler = "ReadAndWrite.readwritedata"
      timeout = 8
    }
    filehandler = {
      source_filename = "FileHandler.py" 
      output_filename = "FileHandler.zip"
      function_name = "FileHandler"
      handler = "FileHandler.handle"
      timeout = 12
    }
    filehandlerasync = {
      source_filename = "FileHandlerAsync.py"
      output_filename = "FileHandlerAsync.zip"
      function_name = "FileHandlerAsync"
      handler = "FileHandlerAsync.handle"
      timeout = 12
    }
    s3_uploader = {
      source_filename = "S3_Uploader.py"
      output_filename = "S3_Uploader.zip"
      function_name = "S3_Uploader"
      handler = "S3_Uploader.handle_img_upld"
      timeout = 12
    }
    pdf_s3_uploader = {
      source_filename = "S3_Uploader.py"
      output_filename = "S3_pdf_uploader.zip"
      function_name = "PDF_S3_Uploader"
      handler = "S3_Uploader.handle_textract_to_s3"
      timeout = 12
    }
    cors_provider = {
      source_filename = "CORSProvider.py"
      output_filename = "CORSProvider.zip"
      function_name = "CORSProvider"
      handler = "CORSProvider.handle"
      timeout = 8
    }
  }
}

## API Gateway
module "rest_apigateway" {
  source = "./modules/aws-apigatewayv2"

  api_name = "serverless_api"
  description = "API Gateway V2"
  apigateway = {
    hello_world = {
      route_key = "GET /test",
      integration_uri = lookup(module.lambda_functions.arn,"HelloWorld")
      lambda_function_name = lookup(module.lambda_functions.function_name,"HelloWorld")
    }
    read_write = {
      route_key = "POST /readwrite",
      integration_uri = lookup(module.lambda_functions.arn,"ReadAndWrite")
      lambda_function_name = lookup(module.lambda_functions.function_name,"ReadAndWrite")
    }
    filehandler = {
      route_key = "POST /readwritefile",
      integration_uri = lookup(module.lambda_functions.arn, "FileHandler")
      lambda_function_name = lookup(module.lambda_functions.function_name,"FileHandler")
    }    
    filehandlerasync = {
      route_key = "POST /readwritefileasync",
      integration_uri = lookup(module.lambda_functions.arn, "FileHandlerAsync")
      lambda_function_name = lookup(module.lambda_functions.function_name,"FileHandlerAsync")
    }
    s3_uploader = {
      route_key = "POST /s3upld",
      integration_uri = lookup(module.lambda_functions.arn, "S3_Uploader")
      lambda_function_name = lookup(module.lambda_functions.function_name, "S3_Uploader")
    }
  }
}
