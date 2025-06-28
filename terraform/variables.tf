variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default = "10.0.1.0/24"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16" 
}

variable "db_name" {
  type = string
}