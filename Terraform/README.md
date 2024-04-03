# Terraform - Modules
## Resources:
```
├── VPC                   # VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway, Transit Gateway, Routes.
├── NACL                  # Network ACLs, Inbound and Outbound rules.
├── SG                    # Security Groups, Inbound and Outbound rules.
├── Endpoints             # VPC endpoints for CloudWatch, ECR and Secrets Manager.
├── MQ (Apache ActiveMQ)  # Message broker service.
├── RDS (PostgreSQL)      # PostgreSQL Database.
├── ALB                   # Application Load Balancer, HTTPS Listener, Rules.
├── Route53 (Private)     # DNS.
├── Cloud Map             # Define user-friendly names.
├── ECS (Fargate)         # Elastic Container Service with AWS Fargate.
```

## Architecture Diagram:
![](https://github.com/kloudpepper/IaC/blob/main/Terraform/images/architecture_diagram_2.png)