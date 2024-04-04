output "application_sg_id" {
  value = aws_security_group.application-sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion-sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
}

output "mongodb_sg_id" {
  value = aws_security_group.mongodb-sg.id
}
