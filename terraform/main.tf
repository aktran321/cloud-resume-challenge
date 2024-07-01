# Archive the Lambda function code
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/lambda/func.py"
  output_path = "${path.module}/lambda/func.zip"
}

# Define the Lambda function using the existing IAM role
resource "aws_lambda_function" "myfunc" {
  filename         = data.archive_file.zip_the_python_code.output_path
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  function_name    = "myfunc"
  role             = "arn:aws:iam::631242286372:role/service-role/cloud-resume-views-role-bnt3oikr" # Existing IAM role ARN
  handler          = "func.lambda_handler"
  runtime          = "python3.12"
}

# Define the Lambda function URL
resource "aws_lambda_function_url" "url1" {
  function_name      = aws_lambda_function.myfunc.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}
