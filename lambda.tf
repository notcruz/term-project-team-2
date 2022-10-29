/*
 *  =======================================
 *        NOTE: UPDATE FILENAMES AND 
 *     FUNCTION NAMES WHEN CODE IS READY
 *  =======================================
 */


/*
 *  =======================================
 *             Lambda Source Code
 *  =======================================
 */

data "archive_file" "lambda_archive" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src.zip"
}

/*
 *  ========================================
 *          Lambda Function Object 
 *      (This is what gets stored on S3)
 *  ========================================
 */

resource "aws_s3_object" "lambda_object" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "src.zip"
  source = data.archive_file.lambda_archive.output_path

  etag = filemd5(data.archive_file.lambda_archive.output_path)
}

/*
 *  ========================================
 *             Lambda Functions
 *  ========================================
 */

resource "aws_lambda_function" "main_lambda" {
  function_name = "Main_Lambda"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_object.key

  runtime = "python3.7"
  handler = "index.main_lambda_handler"

  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  timeout = 15
}

resource "aws_lambda_function" "check_data_lambda" {
  function_name = "Does_Data_Exist"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_object.key

  runtime = "python3.7"
  handler = "check_data.check_data_handler"

  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  timeout = 15
}

resource "aws_lambda_function" "collection_lambda" {
  function_name = "Collection_Lambda"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_object.key

  runtime = "python3.7"
  handler = "collection.collection_lambda_handler"

  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  timeout = 15
}

resource "aws_lambda_function" "analysis_lambda" {
  function_name = "Analysis_Lambda"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_object.key

  runtime = "python3.7"
  handler = "analysis.analysis_handler"

  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  timeout = 15
}