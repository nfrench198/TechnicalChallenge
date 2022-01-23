#CREATES S3 LOGGING BUCKET FOR VPC FLOW LOGS AND ALB ACCESS LOGS
resource "aws_s3_bucket" "s3logging" {
  bucket        = "french-logging-2022"
  acl           = "log-delivery-write"
  force_destroy = true
  policy        = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::french-logging-2022/*",
      "Principal": {
        "AWS": [
          "arn:aws:iam::127311923021:root"
        ]
      }
    },
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::french-logging-2022/*",
      "Principal": {
        "Service": [
          "delivery.logs.amazonaws.com"
        ]
      },
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Action": [
        "s3:GetBucketAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::french-logging-2022",
      "Principal": {
        "Service": [
          "delivery.logs.amazonaws.com"
        ]
      }
    }
  ]
}
POLICY

  tags = merge(var.default_s3_tags)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

#CREATES S3 IMAGE BUCKET
resource "aws_s3_bucket" "s3images" {
  bucket        = "french-images-2022"
  acl           = "private"
  force_destroy = true
  tags          = merge(var.default_s3_tags)
  lifecycle_rule {
    id      = "Images Rule"
    enabled = true
    prefix  = "Images/"
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
  lifecycle_rule {
    id      = "Logs Rule"
    prefix  = "Logs/"
    enabled = true
    expiration {
      days = 90
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}