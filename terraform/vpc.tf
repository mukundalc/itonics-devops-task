resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "itonics-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "itonics-private-subnet"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "itonics-db-subnet-group"
  subnet_ids = [aws_subnet.private.id]

  tags = {
    Name = "itonics-db-subnet-group"
  }
}
