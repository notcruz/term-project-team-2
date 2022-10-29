/*
 *  ========================================
 *                S3 Buckets
 *        (For Data AND Source Code)
 *  ========================================
 */

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "rit-cloud-team-2-lambda-bucket"

  tags = {
    Name = "Main_Lambda_Bucket"
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
 *  ========================================
 *            Access Privileges
 *  ========================================
 */

resource "aws_s3_bucket_acl" "main_bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
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