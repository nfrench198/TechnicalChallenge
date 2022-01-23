# DATA USED TO SPECIFIY THE ACCOUNT ID IN THE KMS POLICY
data "aws_caller_identity" "current" {}

# CREATING THE AWS KMS KEY FOR EC2 AND ASG
resource "aws_kms_key" "default-ec2-key" {
  description         = "Create Customer Key for encryption. It's not possible to export resource encrypted with default AWS KMS key."
  enable_key_rotation = true
  tags = merge(var.default_kms_tags)

  policy = <<EOF
    {
        "Version": "2012-10-17",
        "Id": "ec2-policy",
        "Statement": [
            {
                "Sid": "Enable IAM User Permissions",
                "Effect": "Allow",
                "Principal": {
                    "AWS": [
                        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
                        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
                    ]
                },
                "Action": "kms:*",
                "Resource": "*"
            }
        ]
    }
  EOF
}

# CREATING ALIAS FOR KMS KEY
resource "aws_kms_alias" "default-ec2-alias" {
  name          = "alias/default-ec2-key"
  target_key_id = aws_kms_key.default-ec2-key.key_id
}

# SETTING THE DEFAULT EC2 EBS ENCYPTION KEY
resource "aws_ebs_default_kms_key" "default-ec2-kms" {
  key_arn = aws_kms_key.default-ec2-key.arn
}

# ENFORCING EBS KMS ENCYPTION
resource "aws_ebs_encryption_by_default" "enable-ebs-default" {
  enabled = true
}  