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
Note: If you select the prod environment and want to delete the resources after the test, you must deactivate Deletion Protection on Aurora and ALB through AWS Console before deleting.

![Screenshot](https://github.com/kloudpepper/IaC/tree/main/CloudFormation/images/architecture_diagram.png)