#OUTPUTS
output "s3_logging_bucket" {
  description = "The name of the bucket."
  value       = element(concat(aws_s3_bucket.s3logging.*.id, [""]), 0)
}

output "s3_logging_bucket_arn" {
  description = "The ARN of the bucket."
  value       = element(concat(aws_s3_bucket.s3logging.*.arn, [""]), 0)
}