
/*
 * Initial Cache file that's generated on deployment
 */

resource "aws_s3_object" "object" {
  bucket = "rit-cloud-team-2-cached-data-bucket"
  key = "default_cache"
  source = "src/default_cache.json"
}

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

