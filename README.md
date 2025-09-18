# Terraform AWS ALB Module

A flexible Terraform module to create and manage an Application Load Balancer (ALB), Target Groups, and Listeners on AWS.

## Features

- Creates an Application Load Balancer (internet-facing or internal).
- Supports creating multiple target groups with health checks.
- Supports creating multiple listeners (HTTP/HTTPS).
- Handles HTTP to HTTPS redirection.
- Supports enabling access logs to an S3 bucket.
- Applies common tags to all created resources.

## Usage Example

```terraform
module "my_app_alb" {
  source = "git::[https://github.com/your-org/terraform-aws-alb.git?ref=v1.0.0](https://github.com/your-org/terraform-aws-alb.git?ref=v1.0.0)"

  name               = "my-app-alb"
  vpc_id             = "vpc-12345678"
  subnet_ids         = ["subnet-a1b2c3d4", "subnet-e5f6g7h8"]
  security_group_ids = ["sg-abcdef12"]

  target_groups = {
    "app-tg" = {
      port     = 8080
      protocol = "HTTP"
    }
  }

  listeners = {
    "http-listener" = {
      port             = 80
      protocol         = "HTTP"
      action_type      = "forward"
      target_group_key = "app-tg"
    }
  }

  tags = {
    "Project"     = "MyApp"
    "Environment" = "Production"
  }
}
```

## HashiCorp Terraform Registry Documentation

This module is built on top of the following AWS provider resources. For more detailed information, please refer to the official HashiCorp documentation:

- **[aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)**: Main resource for the Application Load Balancer.
- **[aws_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)**: Resource for the target groups.
- **[aws_lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)**: Resource for the listeners.

## Inputs

| Name                 | Description                                                                 | Type                               | Default | Required |
| -------------------- | --------------------------------------------------------------------------- | ---------------------------------- | ------- | :------: |
| `name`               | The name for the ALB and associated resources.                              | `string`                           | n/a     |   yes    |
| `vpc_id`             | The ID of the VPC where the ALB will be deployed.                           | `string`                           | n/a     |   yes    |
| `subnet_ids`         | A list of subnet IDs to attach to the ALB.                                  | `list(string)`                     | n/a     |   yes    |
| `security_group_ids` | A list of security group IDs to associate with the ALB.                     | `list(string)`                     | n/a     |   yes    |
| `internal`           | If true, the ALB will be internal.                                          | `bool`                             | `false` |    no    |
| `target_groups`      | A map of target groups to create. See variable definition for structure.    | `map(object({...}))`               | `{}`    |    no    |
| `listeners`          | A map of listeners to create. See variable definition for structure.        | `map(object({...}))`               | `{}`    |    no    |
| `access_logs`        | Configuration for ALB access logs. Expects `enabled` and `bucket_name`.     | `object({ enabled, bucket_name })` | `{}`    |    no    |
| `tags`               | A map of tags to apply to all resources.                                    | `map(string)`                      | `{}`    |    no    |

## Outputs

| Name                | Description                                                          |
| ------------------- | -------------------------------------------------------------------- |
| `lb_arn`            | The ARN of the Application Load Balancer.                            |
| `lb_dns_name`       | The DNS name of the Application Load Balancer.                       |
| `lb_zone_id`        | The zone ID of the Application Load Balancer for Route 53 alias records. |
| `target_group_arns` | A map of the ARNs of the created target groups.                      |
| `listener_arns`     | A map of the ARNs of the created listeners.                          |