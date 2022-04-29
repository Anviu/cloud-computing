resource "aws_s3_bucket" "site" {
    bucket = var.bucket_name
    acl = "public-read"

    website {
      index_document = "index.html"
      error_document = "index.html"
    }

    tags = var.tags
}

resource "aws_s3_bucket_policy" "publicRead" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
          {
            Sid = "PublicReadGetObject"
            Effect = "Allow"
            Principal = "*"
            Action="s3:GetObject"
            Resource = [
                aws_s3_bucket.site.arn, "${aws_s3_bucket.site.arn}/*",
            ]
          },
      ]
  })
}

resource "aws_s3_bucket_object" "indexfile" {
  bucket = aws_s3_bucket.site.id
  key = "index.html"
  acl = "public-read"
  source = var.html_source
  content_type = "text/html"

  etag = filemd5(var.html_source)
}

resource "aws_s3_bucket_object" "miscfile" {
  for_each = var.misc_file_data
  bucket = aws_s3_bucket.site.id
  key = each.value.key
  acl = each.value.acl
  source = each.value.source
  content_type = each.value.content_type
}