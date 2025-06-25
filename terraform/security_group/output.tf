output "public-sg-id" {
  value = aws_security_group.public-SG.id
}

output "private-sg-id" {
  value = aws_security_group.private-SG.id
}