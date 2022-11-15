/*
 *  ========================================
 *                S3 Buckets
 *        (For Data AND Source Code)
 *  ========================================
 */

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "rit-cloud-team-2-lambda-bucket-test19"

  tags = {
    Name        = "Main_Lambda_Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "ReactJS_bucket" {
  bucket = "rit-cloud-team-2-ReactJS-bucket-test1"

  tags = {
    Name        = "ReactJS_bucket"
    Environment = "Dev"
  }
}
