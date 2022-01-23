#OUTPUTS
output "default_ec2_kms_arn" {
  value = aws_kms_key.default-ec2-key.arn
}