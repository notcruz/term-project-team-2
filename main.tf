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

  access_key = ""

  secret_key = ""

  token = ""
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