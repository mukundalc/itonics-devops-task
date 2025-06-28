# Rds endpoint for lambda function to connect
output "rds_endpoint" {
  description = "Connect to PostgreSQL"
  value       = aws_db_instance.itonics_db.endpoint
}