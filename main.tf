provider "aws" {
  region = "us-east-1"
}

# Helper resource for unique S3 bucket naming
resource "random_id" "id" {
  byte_length = 4
}

# ------------------------------------------------------------------------------
# STEP 2: AWS Budget Guardrail ($10.00 USD / Monthly, 80% Alert)
# ------------------------------------------------------------------------------
resource "aws_budgets_budget" "tlab_budget" {
  name              = "TLAB-Strict-Budget"
  budget_type       = "COST"
  limit_amount      = "10"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2026-01-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = ["isabelli0056@gmail.com"]
  }
}

# ------------------------------------------------------------------------------
# STEP 3: Secure S3 Storage Vault
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "vault" {
  bucket        = "titan-fintech-vault-id-${random_id.id.hex}"
  force_destroy = true
}

# ------------------------------------------------------------------------------
# STEP 4: IAM Role with Least Privilege (Surgical s3:PutObject Permission)
# ------------------------------------------------------------------------------
# Trust Policy allowing EC2 to assume this role
resource "aws_iam_role" "titan_role" {
  name = "Titan-EC2-Vault-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Custom Policy restricting access to strictly s3:PutObject on the specific bucket
resource "aws_iam_policy" "s3_put_policy" {
  name        = "Titan-S3-PutObject-Policy"
  description = "Allows only s3:PutObject strictly to the Titan Vault bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.vault.arn}/*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_put_policy" {
  role       = aws_iam_role.titan_role.name
  policy_arn = aws_iam_policy.s3_put_policy.arn
}

# Instance Profile container to pass role to EC2
resource "aws_iam_instance_profile" "titan_profile" {
  name = "Titan-EC2-Vault-Instance-Profile"
  role = aws_iam_role.titan_role.name
}

# ------------------------------------------------------------------------------
# STEP 5: Ubuntu Compute Instance wearing the Titan Role
# ------------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official Ubuntu ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "titan_compute" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.titan_profile.name

  tags = {
    Name = "Titan-FinTech-EC2"
  }
}