# AWS CloudFormation - Nested stacks
## Resources:
```
├── ROOT                # Root template (Nested stacks).
├── VPC                 # VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway, Transit Gateway, Routes.
├── NACL                # Network ACLs, Inbound and Outbound rules.
├── SG                  # Security Groups, Inbound and Outbound rules.
├── Endpoints           # VPC endpoints for CloudWatch, ECR and Secrets Manager.
├── EFS                 # File storage.
├── PCA / ACM           # Load Balancer's Certificate.
├── ALB                 # Application Load Balancer, HTTPS Listener, Rules.
├── RDS (Aurora)        # Amazon Aurora Database with MySQL compatibility.
├── Route53 (Private)   # DNS.
├── ECS (Fargate)       # Container cluster with AWS Fargate
```