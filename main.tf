## =============================================================================
#  IAM for S3 Bucket - USE1 (N. VA) - Cluster C                                #
## =============================================================================
# Provides the AWS account ID to other resources
# Interpolate: data.aws_caller_identity.current.account_id
data "aws_caller_identity" "current" {}

# Create user and access keys
resource "aws_iam_user" "nova-iam-user" {
  name = "nova-iam-svc-use1"
}

resource "aws_iam_access_key" "nova-iam-user-key" {
  user = aws_iam_user.nova-iam-user.name
}

# Create IAM policy
resource "aws_iam_policy" "nova-cloud-out" {
  name = "nova-cloud-out-policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RubrikCloudOutS3All",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        },
        {
            "Sid": "RubrikCloudOutS3Restricted",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:DeleteObject",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts",
                "s3:RestoreObject"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "nova-cloud-out" {
    user       = aws_iam_user.nova-iam-user.name
    policy_arn = aws_iam_policy.nova-cloud-out.arn
}

resource "aws_iam_policy" "nova-cloud-on" {
  name = "nova-cloud-on-policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid":  "RubrikCloudOnv50",
            "Effect": "Allow",
            "Action": [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:GenerateDataKeyWithoutPlaintext",
              "kms:GenerateDataKey",
              "kms:DescribeKey",
              "ec2:DescribeInstances",
              "ec2:CreateKeyPair",
              "ec2:CreateImage",
              "ec2:CopyImage",
              "ec2:DescribeSnapshots",
              "ec2:DeleteVolume",
              "ec2:StartInstances",
              "ec2:DescribeVolumes",
              "ec2:DescribeExportTasks",
              "ec2:DescribeAccountAttributes",
              "ec2:ImportImage",
              "ec2:DescribeKeyPairs",
              "ec2:DetachVolume",
              "ec2:CancelExportTask",
              "ec2:CreateTags",
              "ec2:RunInstances",
              "ec2:StopInstances",
              "ec2:CreateVolume",
              "ec2:DescribeImportSnapshotTasks",
              "ec2:DescribeSubnets",
              "ec2:AttachVolume",
              "ec2:DeregisterImage",
              "ec2:ImportVolume",
              "ec2:DeleteSnapshot",
              "ec2:DeleteTags",
              "ec2:DescribeInstanceAttribute",
              "ec2:DescribeAvailabilityZones",
              "ec2:CreateSnapshot",
              "ec2:ModifyInstanceAttribute",
              "ec2:DescribeInstanceStatus",
              "ec2:CreateInstanceExportTask",
              "ec2:TerminateInstances",
              "ec2:ImportInstance",
              "s3:CreateBucket",
              "s3:ListAllMyBuckets",
              "ec2:DescribeTags",
              "ec2:CancelConversionTask",
              "ec2:ImportSnapshot",
              "ec2:DescribeImportImageTasks",
              "ec2:DescribeSecurityGroups",
              "ec2:DescribeImages",
              "ec2:DescribeVpcs",
              "ec2:CancelImportTask",
              "ec2:DescribeConversionTasks"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "nova-cloud-on" {
    user       = aws_iam_user.nova-iam-user.name
    policy_arn = aws_iam_policy.nova-cloud-on.arn
}

## =============================================================================
#  KMS Key for S3 Bucket - USE1 (N. VA) - Cluster C                            #
## =============================================================================
resource "aws_kms_key" "nova-kms" {
  description   = "KMS key for Rubrik CloudOut and CloudOn"
  tags = {
    Name        = "nova-kms-s3-use1"
    environment = var.aws_environment_name
    managed-by  = "Terraform"
    rubrik-cdm  = var.aws_rubrik_cdm
    use-case    = "rubrik-archive"
  }

  policy = <<EOF
{
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                  "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.nova-iam-user.name}"
                ]
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                  "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.nova-iam-user.name}"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_kms_alias" "nova-kms-alias" {
  target_key_id = aws_kms_key.nova-kms.key_id
  name          = "alias/nova-kms-s3-use1"
}

## =============================================================================
#  S3 Bucket - USE1 (N. VA) - Cluster C                                        #
## =============================================================================
resource "aws_s3_bucket" "nova-s3-use1-c" {
  bucket = "nova-s3-use1-c"
  acl    = "private"
  versioning {
    enabled = true
  }

  tags = {
    Name        = "nova-s3-use1-c"
    environment = var.aws_environment_name
    managed-by  = "Terraform"
    rubrik-cdm  = var.aws_rubrik_cdm
    use-case    = "rubrik-archive"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.nova-kms.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Provides additional layers of security to block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "nova-s3-use1-c" {
  bucket                  = aws_s3_bucket.nova-s3-use1-c.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## =============================================================================
#  Security Group for Bolt - USE1 (N. VA) - Cluster C                          #
## =============================================================================
resource "aws_security_group" "nova-bolt-sg-use1-c" {
  name                = "nova-bolt-sg-use1-c"
  description         = "Security group to allow access from lab to Bolt"
  vpc_id              = var.aws_vpc

  ingress {
    from_port   = 2002
    to_port     = 2002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow lab to Bolt port 2002"
  }

  egress {
    from_port   = 7780
    to_port     = 7780
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow lab to Bolt port 7780"
  }

    tags = {
    Name        = "nova-bolt-sg-use1-c"
    environment = var.aws_environment_name
    managed-by  = "Terraform"
    rubrik-cdm  = var.aws_rubrik_cdm
    use-case    = "rubrik-bolt"
  }
}