#############################################################################################################
# This file contains the configuration for the backend infrastructure	
# The backend infrastructure includes the S3 bucket and DynamoDB table used to store the Terraform state file
#############################################################################################################

# Resource S3 bucket
resource "aws_s3_bucket" "tf_challenge_bucket" {
  bucket = "tf-challenge-state-bucket"

  tags = {
    Name        = "TerraformStateBucket"
    Environment = "dev"
  }
}


# Enable Versioning
resource "aws_s3_bucket_versioning" "tf_challege_version" {
  bucket = aws_s3_bucket.tf_challenge_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Resource bucket ownership configuration
resource "aws_s3_bucket_ownership_controls" "tf_ownership" {
  bucket = aws_s3_bucket.tf_challenge_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Enable S3 bucket resource access 
resource "aws_s3_bucket_acl" "tf_challenge_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.tf_ownership]
  bucket     = aws_s3_bucket.tf_challenge_bucket.id
  acl        = "private"
}


# Enable Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_challenge_encryption" {
  bucket = aws_s3_bucket.tf_challenge_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


################################ DYNAMO DB ##########################################
# Create DynamoDB
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "tf-challenge-state-lock"
  billing_mode = "PAY_PER_REQUEST"

  # Define the schema for locking
  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"

  tags = {
    Name        = "TerraformLockTable"
    Environment = "Production"
  }
}