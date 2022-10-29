/*
 *  =========================================
 *      IAM Role and Policy for Lambdas
 *  (Update these to use LabRole for Academy)
 *  =========================================
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
    resources = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:states:us-east-1:574488233764:stateMachine:*", "arn:aws:states:us-east-1:574488233764:execution:main-step-function:*"]
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

/*
 *  =========================================
 *    IAM Role and Policy for Step Function
 *  (Update these to use LabRole for Academy)
 *  =========================================
 */

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