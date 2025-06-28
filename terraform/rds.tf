# Creates RDS PostgreSQL Instance
resource "aws_db_instance" "itonics_db" {
  identifier             = "itonics-db"
  engine                 = "postgres"
  engine_version         = "14.4"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  password               = random_string.rds_password.result
  parameter_group_name   = "default.postgres14"
  skip_final_snapshot    = false
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]
}

# Allow Lambda to access RDS
resource "aws_security_group" "rds" {
  name        = "itonics-rds-sg"
  description = "Allow inbound PostgreSQL"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# Initialize DB with sql scripts
resource "null_resource" "db_setup" {
  depends_on = [aws_db_instance.itonics_db]

  provisioner "local-exec" {
    command = <<EOT
      psql postgresql://itonics_owner:${random_string.rds_password.result}@${aws_db_instance.itonics_db.endpoint}/itonics -f ${path.module}/sql/01-create-users.sql
      psql postgresql://itonics_owner:${random_string.rds_password.result}@${aws_db_instance.itonics_db.endpoint}/itonics -f ${path.module}/sql/02-create-messages.sql
    EOT
  }
}

# Stores the password in SSM Parameter Store for security
resource "aws_ssm_parameter" "rds_password_param" {
  name        = "/itonics/rds/password"
  type        = "SecureString"
  value       = random_string.rds_password.result
  description = "RDS DB password for myapp"
  overwrite   = true
}