# Terraform
## Resources:
```
├── aws_backup_restore_testing   # Automated restore validation using AWS Backup + Step Functions
├── eventbridge-scheduler       # Scheduled executions (e.g., Lambda triggers, automation workflows)
├── lambda_rotate_api_key       # Lambda for API Gateway key rotation + CloudFront + Secrets Manager sync
├── lambda_sync_s3              # Lambda to synchronize data with S3 buckets
├── project_infra               # Core infrastructure (shared resources, networking, base services)
├── README.md
```

---

## 🔧 Modules Description

### 🟢 aws_backup_restore_testing

Automates backup restore validation using:

- AWS Backup Restore Testing  
- AWS Step Functions (no Lambda approach)  
- RDS Data API for validation queries  

---

### ⏱️ eventbridge-scheduler

Defines scheduled executions using EventBridge:

- Triggers Lambda functions  
- Supports retry policies and execution windows  
- Used for periodic automation (e.g., key rotation)  

---

### 🔐 lambda_rotate_api_key

Handles API key lifecycle:

- Rotates API Gateway API keys  
- Updates AWS Secrets Manager  
- Updates CloudFront custom headers (`x-api-key`)  
- Supports multi-application key management  

---

### 🔄 lambda_sync_s3

Synchronizes data to/from S3:

- Batch processing  
- Automation for file consistency  
- Useful for integrations or data pipelines  

---

### 🏗️ project_infra

Core infrastructure layer:

- Base AWS resources  
- Shared components  
- Environment-specific configuration (int / pre / prod)  

---

## 🧱 Architecture Overview

This repository follows a modular and automation-first approach, where:

- Infrastructure is defined using Terraform modules  
- Operational tasks are implemented as serverless workflows  
- Event-driven automation is preferred over manual execution  

---

## 🚀 Key Principles

- Infrastructure as Code (IaC) using Terraform  
- Serverless-first approach (Lambda, Step Functions, EventBridge)  
- Automation over manual operations  
- Reusable and modular design  
- Multi-environment support (int / pre / prod)  