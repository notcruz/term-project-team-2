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
 *  (UPDATE THESE FOR USE WITH YOUR OWN ACCOUNT)
 *  ========================================
 */

provider "aws" {
  region = "us-east-1"

  access_key = "ASIAQCQUY6GCZ6TFQMOP"

  secret_key = "E7NOu2ZsIXT8KQ4TXfXKgEbyMzIbD844ZJf5lvdR"

  token = "FwoGZXIvYXdzEJD//////////wEaDI3m/tk4FXqrlMhNRiK/AZHFZVOxOp35DvGvl3/sI4Hexnp7a/I3NE4l7I5JtPnMK+B2fWZA4RFOe5Hz729/g6ZkqqY5D7hix2xdNf30PJkExRjciXCpCdoH1+WZZZn2EMrSo1/aixxlGf2bzKS0pLaGKzuCluHnrx0TPUrG6/jbZuX2sEskvndYp6UMyKdEhkiTICswa3LDFHIbDzt+ccYm8ibYXS+HTpt6VjzRPP3dRbwPhXtnrdI7U/+u1/DhQwD45/9NKywro7oHjMkcKJqA/JoGMi0OiJbfT7DP1VdhtxSoNICrCQcua8KBWjBjzdkW/u0VRYZY+ZyuKhzbpV/ito0="
}

/*
 *  ========================================
 *             Step Function
 *  ========================================
 */

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "main-step-function"
  role_arn = "arn:aws:iam::005412286853:role/LabRole"

  definition = <<EOF
{
  "Comment": "Main Step Function",
  "StartAt": "CheckCurrentData",
  "States": {
    
    "CheckCurrentData": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.check_data_lambda.arn}",
      "Next":  "DoesDataExist"
    },

    "DoesDataExist": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.data",
          "IsNull": false,
          "Next": "Success"      
        },
        {
          "Variable": "$.data",
          "IsNull": true,
          "Next": "CollectAndStore"  
        }]
    },

    "CollectAndStore": {
      "Type": "Task",
      "InputPath": "$.name",
      "Resource": "${aws_lambda_function.collection_lambda.arn}",
      "Next": "ConductAnalysis"
    },

    "ConductAnalysis": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.analysis_lambda.arn}",
      "End": true
    },

    "Success": {
      "Type": "Succeed"
    }
  }
}

EOF
}


resource "aws_dynamodb_table" "cache_table" {
  name           = "CachedPeople"
  billing_mode   = "PROVISIONED"
  read_capacity  = 50
  write_capacity = 50
  hash_key       = "Name"
  range_key      = "CurrentScore"

  attribute {
    name = "Name"
    type = "S"
  }

  attribute {
    name = "CurrentScore"
    type = "S"
  }

  tags = {
    Name        = "cache_table"
    Environment = "production"
  }
}