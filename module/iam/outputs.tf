#OUTPUTS
output "ec2_iam_name" {
  value = aws_iam_instance_profile.default_ec2_profile.name
}