provider "aws" {  
  region = "us-east-1"
}

# The Guardrail
resource "aws_budgets_budget" "tlab_budget" {  
  name              = "TLAB-Strict-Budget"  
  budget_type       = "COST"  
  limit_amount      = "50"  
  limit_unit        = "USD"  
  time_unit         = "MONTHLY"  

  notification {    
    comparison_operator        = "GREATER_THAN"    
    notification_type          = "ACTUAL"    
    threshold                  = 100    
    threshold_type             = "PERCENTAGE"    
    subscriber_email_addresses = ["admin@example.com"]  
  }
}

# The Target Identity
resource "aws_iam_user" "tlab_user" {  
  name = "tlab-service-account"
}

# SABOTAGE 1: Dangerously broad permissions attached directly to a user
resource "aws_iam_user_policy" "tlab_user_policy" {  
  name = "tlab-unrestricted-access"  
  user = aws_iam_user.tlab_user.name  

  policy = jsonencode({    
    Version = "2012-10-17"    
    Statement = [      
      {        
        Action = [          
          "ec2:*",          
          "s3:*"        
        ]        
        Effect = "Allow"        
        # BUG: Broad resource access violates least privilege
        Resource = "*"      
      }    
    ]  
  })
}