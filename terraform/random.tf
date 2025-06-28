resource "random_string" "rds_password" {
  length  = 14
  upper   = true
  lower   = true
  numeric = true
  special = false
}
