resource "aws_s3_bucket" "remote_s3" {
  bucket = "pk-terraf-state-bucket"

  tags = {
    Name        = "pk-terraf-state-bucket"
  }
}