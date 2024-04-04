output "application_dns_name" {
  value = aws_lb.alb1.dns_name
}

output "application_private_ips" {
  value       = data.aws_instances.application.private_ips
  description = "application instance private ips"
}
