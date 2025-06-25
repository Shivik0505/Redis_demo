#instenses ID
output "pub-instance-id" {
  value = aws_instance.redis-public.id
}

output "private-instance1-id" {
  value = aws_instance.redis-private-1.id
}

output "private-instance2-id" {
  value = aws_instance.redis-private-2
}

output "private-instance3-id" {
  value = aws_instance.redis-private-3
}

# instences IP addresses
output "public-instance-ip" {
  value = aws_instance.redis-public.public_ip
}

output "private-instance1-ip" {
  value = aws_instance.redis-private-1.private_ip
}

output "private-instance2-ip" {
  value = aws_instance.redis-private-2.private_ip
}

output "private-instance3-ip" {
  value = aws_instance.redis-private-3.private_ip
}