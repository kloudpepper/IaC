# Terraform - Modules
## Resources:
```
├── VPC                 # VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway, Transit Gateway, Routes.
├── NACL                # Network ACLs, Inbound and Outbound rules.
├── SG                  # Security Groups, Inbound and Outbound rules.
├── Endpoints           # VPC endpoints for CloudWatch, ECR and Secrets Manager.
├── MQ                  # File storage.
├── ALB                 # Application Load Balancer, HTTPS Listener, Rules.
├── RDS (PostgreSQL)    # PostgreSQL Database.
├── Route53 (Private)   # DNS.
├── Cloud Map           # Define user-friendly names.
├── EKS (Fargate)       # Kubernetes cluster with AWS Fargate.
```
Note: If you select the **prod** environment and want to delete the resources after the test, you must deactivate **Deletion Protection** on PostgreSQL and ALB through AWS Console before deleting.

## Architecture Diagram:
![](https://github.com/kloudpepper/IaC/blob/main/CloudFormation/images/architecture_diagram.png)