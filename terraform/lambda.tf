# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "itonics-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# RDS access policy (custom)
resource "aws_iam_policy" "rds_access" {
  name        = "itonics-lambda-rds-policy"
  description = "Allow Lambda to access RDS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["rds-db:connect"],
      Effect   = "Allow",
      Resource = "aws_db_instance.itonics_db.arn"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_rds" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.rds_access.arn
}

# Lambda function
resource "aws_lambda_function" "messages_api" {
  filename      = "./backend/message-api.zip"
  function_name = "messages-api"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 10

  environment {
    variables = {
      PG_HOST     = aws_db_instance.itonics_db.endpoint
      PG_DATABASE = "itonics"
      PG_USER     = "itonics_owner"
      PG_PASSWORD = random_string.rds_password.result
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_rds
  ]
}