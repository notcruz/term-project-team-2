resource "aws_dynamodb_table" "cache_table" {
  name           = "CachedPeople"
  billing_mode   = "PROVISIONED"
  read_capacity  = 50
  write_capacity = 50
  hash_key       = "Name"

  attribute {
    name = "Name"
    type = "S"
  }

  tags = {
    Name        = "cache_table"
    Environment = "production"
  }
}

resource "aws_dynamodb_table" "raw_data_table" {
  name = "RawDataTable"
  billing_mode = "PROVISIONED"
  read_capacity = 50
  write_capacity = 50
  hash_key = "Name"

  attribute {
    name = "Name"
    type = "S"
  }

  tags = {
    Name = "raw_data_table"
    Environment = "production"
  }

}
