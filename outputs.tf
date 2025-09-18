output "lb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "lb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "lb_zone_id" {
  description = "The zone ID of the Application Load Balancer for Route 53 alias records."
  value       = aws_lb.main.zone_id
}

output "target_group_arns" {
  description = "A map of the ARNs of the created target groups."
  value       = { for key, tg in aws_lb_target_group.main : key => tg.arn }
}

output "listener_arns" {
  description = "A map of the ARNs of the created listeners."
  value       = { for key, listener in aws_lb_listener.main : key => listener.arn }
}
