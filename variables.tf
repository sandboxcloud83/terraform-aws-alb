variable "name" {
  description = "The name for the ALB and associated resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs to attach to the ALB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the ALB."
  type        = list(string)
}

variable "internal" {
  description = "If true, the ALB will be internal. If false, it will be internet-facing."
  type        = bool
  default     = false
}

variable "target_groups" {
  description = "A map of target groups to create. The key is a logical name for the target group."
  type = map(object({
    port                 = number
    protocol             = string
    target_type          = optional(string, "instance")
    health_check_path    = optional(string, "/")
    health_check_port    = optional(string, "traffic-port")
    health_check_matcher = optional(string, "200-399")
  }))
  default = {}
}

variable "listeners" {
  description = "A map of listeners to create. The key is a logical name for the listener."
  type = map(object({
    port              = number
    protocol          = string
    certificate_arn   = optional(string)
    action_type       = string # "forward" or "redirect"
    target_group_key  = optional(string)
    redirect = optional(object({
      protocol    = string
      port        = string
      status_code = string
    }))
  }))
  default = {}
}

variable "access_logs" {
  description = "Configuration for ALB access logs."
  type = object({
    enabled     = optional(bool, false)
    bucket_name = optional(string)
    prefix      = optional(string)
  })
  default = {}
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "listener_ssl_policy" {
  description = "The SSL security policy for HTTPS listeners. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06" # A modern, recommended policy
}

variable "drop_invalid_header_fields" {
  description = "Indicates whether HTTP headers with invalid header fields are removed by the load balancer."
  type        = bool
  default     = true
}
