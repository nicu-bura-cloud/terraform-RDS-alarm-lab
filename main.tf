provider "aws" {
  region = "eu-west-1"
}
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-nicubura-sg"
  description = "Allow Postgres from my IP"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  tags = {
    Name = "rds-nicubura-sg"
  }
}
resource "aws_db_instance" "db_nicuBura" {
  identifier           = "db-nicubura"
  engine              = "postgres"
  engine_version      = "15.17"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = "nicuburadb"
  username            = "nicubura"
  password            = "var.db_password" 
  publicly_accessible = true
  skip_final_snapshot = true
vpc_security_group_ids = [aws_security_group.rds_sg.id]  # <-- AGGIUNGI QUESTA RIGA

}

output "rds_endpoint" {
  value = aws_db_instance.db_nicuBura.endpoint
}
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "rds-nicubura-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "CPU RDS > 60% per 1 minuto"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.db_nicuBura.identifier
  }
}
variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}
