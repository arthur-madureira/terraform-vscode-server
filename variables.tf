# Região AWS onde os recursos serão criados
variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  default     = "sa-east-1"
}

# AMI utilizada para criar a instância EC2
variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0a174b8e659123575"
}

# Tipo da instância EC2
variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "m7i-flex.large"
}
