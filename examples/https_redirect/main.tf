# --- 1. Create the Network using our VPC module ---
module "vpc" {
  source = "../../../terraform-aws-vpc"
  name               = "example-vpc"
  availability_zones = ["us-east-1a", "us-east-1b"]
  enable_flow_logs   = true

  tags = {
    Name        = "example-vpc"
    Environment = "development"
    Project     = "vpc-module-testing"
    ManagedBy   = "Terraform"
  }
}

module "kms_key_for_logs" {
  source = "../../../terraform-aws-kms"
  key_description      = "KMS key for VPC flow logs encryption"
  alias_name           = "alias/vpc-flow-logs"
  tags = {
    Name = "kms-vpc-flow-logs"
  }
}

# --- 2. Create the Security Group using our SG module ---
module "alb_sg" {
  source = "../../../terraform-aws-security-group"
  name   = "alb-redirect-example-sg"
  description = "Security Group for the ALB example"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    "Terraform-Example" = "https-redirect-prereq"
    "Managed-By"        = "Terraform"
  }
}

# --- 3. Self-signed certificate for testing purposes (unchanged) ---
# --- Prerequisite: LOOK UP an existing Route 53 Hosted Zone ---
# Instead of creating a resource, we use a data source to find
# the pre-existing hosted zone. This makes the example declarative.
data "aws_route53_zone" "example" {
  name = var.test_domain_name
}

# --- Module Invocation ---
# The module call remains the same, but it now receives the domain
# name from the variable, which refers to an existing resource.
module "acm_certificate_example" {
  source = "../../../terraform-aws-acm"
  domain_name               = data.aws_route53_zone.example.name
  subject_alternative_names = ["www.${data.aws_route53_zone.example.name}"]
  tags = {
    "Terraform-Example" = "acm"
    "Managed-By"        = "Terraform"
  }
}


# -----------------------------------------------------------------------------
# Module Invocation - NOW WIRED TO OUR MODULES' OUTPUTS
# -----------------------------------------------------------------------------

module "https_redirect_alb" {
  source = "../../"
  name               = "https-redirect-alb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.alb_sg.security_group_id]

  target_groups = {
    "secure-app" = {
      port     = 443
      protocol = "HTTPS"
    }
  }

  listeners = {
    "http-redirect" = {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        protocol    = "HTTPS"
        port        = "443"
        status_code = "HTTP_301"
      }
    },
    "https" = {
      port             = 443
      protocol         = "HTTPS"
      action_type      = "forward"
      certificate_arn  = module.acm_certificate_example.certificate_arn
      target_group_key = "secure-app"
    }
  }

  tags = {
    "Terraform-Example" = "https_redirect"
    "Managed-By"        = "Terraform"
  }
}
