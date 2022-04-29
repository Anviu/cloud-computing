data "archive_file" "archive_lambda" {
  for_each = var.lambda_data
  type        = "zip"
  source_dir = "${path.root}/${var.zip_output_root}/deployment_package_${each.value.function_name}"
  output_file_mode = "0666"
  output_path = "${null_resource.install_python_dependencies[each.key].triggers.filename}"

}


resource "null_resource" "install_python_dependencies" {
  for_each = var.lambda_data
  triggers = {
    always_run = "${timestamp()}"
    filename = "${path.root}/${var.zip_output_root}/${each.value.output_filename}"
  }
  provisioner "local-exec" {
    command = "./${path.module}/scripts/create_dependency.sh"
    environment = {
      function_name = "Lambda"
      runtime = "python3.9"
      path_files = "lambda_functions"
      path_build = "build/zip"
      servicename = each.value.function_name
      filename = each.value.source_filename
    }
  }
}



resource "aws_lambda_function" "lambda" {
  for_each = var.lambda_data
  filename      = data.archive_file.archive_lambda[each.key].output_path
  function_name = each.value.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = each.value.handler
  timeout       = each.value.timeout

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    null_resource.install_python_dependencies
  ]

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"

  source_code_hash = filebase64sha256(data.archive_file.archive_lambda[each.key].output_path)

  runtime = "python3.9"
}

## Lambda IAM
resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda_exec_policy"
  path        = "/"
  description = "My lambda policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
        Sid      = "Stmt1562499798378"
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_lambda_policy" {
  name = "lambda_lambda_policy"
  path = "/"
  description = "Allow lambda to access other lambdas directly"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:lambda:*"
        Sid      = "Stmt1562499798378"
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name = "lambda_s3_policy"
  path = "/"
  description = "Allow lambda access to s3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
        Sid      = "Stmt1562499798378"
      },
    ]
  })
}


resource "aws_iam_policy" "lambda_textract_policy" {
  name = "lambda_textract_policy"
  path = "/"
  description = "Allow lambda access to textract"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "textract:*",
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid      = "Stmt1562499798378"
      },
    ]
  })
}



resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_attatch" {
  name = "s3_attatch"
  roles = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
	role       = aws_iam_role.lambda_role.name
	policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

resource "aws_iam_policy_attachment" "textract_attatch" {
  name = "textract_attatch"
  roles = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_textract_policy.arn
}

resource "aws_iam_policy_attachment" "l_l_policy_attachment" {
  name = "l_l_attatch"
  roles = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_lambda_policy.arn
}
