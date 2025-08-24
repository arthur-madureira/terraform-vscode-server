# Exibe o ID da instância EC2 criada
output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.example.id
}

# Exibe o IP público da instância EC2 criada
output "public_ip" {
  description = "The public IP of the EC2 instance."
  value       = aws_instance.example.public_ip
}
