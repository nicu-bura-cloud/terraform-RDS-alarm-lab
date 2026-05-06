cat > README.md << 'EOF'
# Terraform RDS + CloudWatch Alarm Lab

Deploy AWS RDS PostgreSQL t3.micro con Terraform + CloudWatch Alarm su CPU > 80%.

## Architettura
- **RDS PostgreSQL 15.3** `db.t3.micro` - Free Tier eligible
- **Security Group** porta 5432 aperta solo al tuo IP
- **CloudWatch Alarm** `CPUUtilization > 80%` per 5 min
- **Costo**: $0 se distrutto dopo il test

## Stress Test
Usato `pgbench` da EC2 per saturare la CPU e triggerare l'alarm:
```bash
pgbench -h <rds-endpoint> -U testuser -i testdb
pgbench -h <rds-endpoint> -U testuser -c 10 -T 300 testdb
