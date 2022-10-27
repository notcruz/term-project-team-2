terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

/*
 *  ========================================
 *             AWS Credentials
 *  ========================================
 */

provider "aws" {
  region = "us-east-1"
}

/*
 *  ========================================
 *             Lambda Buckets
 *  ========================================
 */


resource "aws_s3_bucket" "main_lambda_bucket" {
  bucket = "rit-cloud-team-2-main-lambda-bucket"

  tags = {
    Name = "Main_Lambda_Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "collection_lambda_bucket" {
  bucket = "rit-cloud-team-2-collection-lambda-bucket"

  tags = {
    Name = "Collection_Lambda_Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "raw_data_bucket" {
  bucket = "rit-cloud-team-2-raw-data-bucket"

  tags = {
    Name = "Raw_Data_Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "cache_bucket" {
  bucket = "rit-cloud-team-2-cached-data-bucket"

  tags = {
    Name = "Cached_Data_Bucket"
    Environment = "Dev"
  }
}

/*
 * Access Privileges for buckets (all private)
 */

resource "aws_s3_bucket_acl" "main_bucket_acl" {
  bucket = aws_s3_bucket.main_lambda_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "collection_bucket_acl" {
  bucket = aws_s3_bucket.collection_lambda_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "raw_data_bucket_acl" {
  bucket = aws_s3_bucket.raw_data_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "cache_bucket_acl" {
  bucket = aws_s3_bucket.cache_bucket.id
  acl    = "private"
}


/*
 *  ========================================
 *             Lambda Functions
 *  ========================================
 */

data "archive_file" "main_lambda" {
  type = "zip"

  /* Add code to call step function */
  source_dir  = "${path.module}/src/main"
  output_path = "${path.module}/main.zip"
}

data "archive_file" "collection_lambda" {
  type = "zip"

  source_dir  = "${path.module}/src/collect"
  output_path = "${path.module}/collect.zip"
}

resource "aws_s3_object" "main_lambda" {
  bucket = aws_s3_bucket.main_lambda_bucket.id

  key    = "src.zip"
  source = data.archive_file.main_lambda.output_path

  etag = filemd5(data.archive_file.main_lambda.output_path)
}

resource "aws_s3_object" "collection_lambda" {
  bucket = aws_s3_bucket.collection_lambda_bucket.id

  key    = "collect.zip"
  source = data.archive_file.collection_lambda.output_path

  etag = filemd5(data.archive_file.main_lambda.output_path)
}

resource "aws_lambda_function" "main_lambda" {
  function_name = "Main_Lambda"

  s3_bucket = aws_s3_bucket.main_lambda_bucket.id
  s3_key    = aws_s3_object.main_lambda.key

  runtime = "python3.7"
  handler = "index.main_lambda_handler"

  source_code_hash = data.archive_file.main_lambda.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  timeout = 15
}

resource "aws_lambda_function" "collection_lambda" {
  function_name = "Collection_Lambda"

  s3_bucket = aws_s3_bucket.collection_lambda_bucket.id
  s3_key    = aws_s3_object.collection_lambda.key

  runtime = "python3.7"
  handler = "collection.collection_lambda_handler"

  source_code_hash = data.archive_file.collection_lambda.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  timeout = 15
}

/*
 *  ========================================
 *             IAM Roles
 *  ========================================
 */

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

data "aws_iam_policy_document" "lambda_exec" {
  statement {
    actions = ["lambda:*", "states:*"]
    resources = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:states:us-east-1:574488233764:stateMachine:*", "arn:aws:states:us-east-1:574488233764:execution:main-state-machine:*"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name = "lambda-function-policy"
  policy = data.aws_iam_policy_document.lambda_exec.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

resource "aws_iam_role" "step_function_exec" {
  name = "step_function_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "states.amazonaws.com"
      }
      }
    ]
  })
}

data "aws_iam_policy_document" "step_function" {
  statement {
    actions = ["lambda:InvokeFunction", "states:*"]
    resources = ["arn:aws:lambda:us-east-1:574488233764:function:Collection_Lambda", "*"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "step_function_policy" {
  name = "step-function-policy"
  policy = data.aws_iam_policy_document.step_function.json
}

resource "aws_iam_role_policy_attachment" "step_function_policy" {
  role       = aws_iam_role.step_function_exec.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}

/*
 *  ========================================
 *             API Gateway
 *  ========================================
 */

resource "aws_apigatewayv2_api" "api_gw" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_gw" {
  api_id = aws_apigatewayv2_api.api_gw.id

  name        = "serverless_lambda_stage"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "api_gw" {
  api_id = aws_apigatewayv2_api.api_gw.id

  integration_uri    = aws_lambda_function.main_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_gw" {
  api_id = aws_apigatewayv2_api.api_gw.id

  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.api_gw.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api_gw.execution_arn}/*/*"
}

/*
 *  ========================================
 *             Step Function
 *  ========================================
 */

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "main-state-machine"
  role_arn = aws_iam_role.step_function_exec.arn

  definition = <<EOF
{
  "Comment": "Lambda function for collecting tweet data",
  "StartAt": "Collect",
  "States": {
    "Collect": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.collection_lambda.arn}",
      "End": true
    }
  }
}

EOF
}