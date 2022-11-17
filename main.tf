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

  access_key="ASIAQQNXEBTSSXZOZMVO"
  secret_key="BkTRXDFVeMXK1y+WNSQScUEbzNv3ovtKFqX6nAN/"
  token="FwoGZXIvYXdzEAgaDHxx3jlfLpwcirgT1SK+AUB42WMe85xnQDlQWiOXHjQ0Z2q64AS/iU0UH1lgVDJZ/rAK6m/oEYyzM3mkefMBUlYpDEooM0ZsCy1Rx0qfLjy2wQRWhl8vW9hrfcPB6zUuzgFDD9aVRoghs9QpN5b0Vj1LIhRlXTi8LuYT0G0ezBfLmPWzo4WNCk1EZ7np4DLhG2a780ETgFmk1Bq2/cw+sCc3BriNZTgEtaXh/CegdcBIeSTG6uTf0AAN0206xLij5vPquiXHuYZ7eOsa/nQo9MnOmwYyLbM1l7r/dt+ExxGVj2lWZrELTGsguCMuUIn/GwBN++OJGcGr67QgghqtTt3OAA=="
}

/*
 *  ========================================
 *             Step Function
 *  ========================================
 */

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "main-step-function"
  role_arn = var.lab_role_arn

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
      "InputPath": "$",
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
