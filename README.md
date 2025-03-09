# KloudPepper - Infrastructure as Code (IaC)

This repository contains infrastructure templates for provisioning and managing cloud resources across multiple IaC tools.

## Overview

This project organizes infrastructure code across different IaC frameworks, allowing for flexible deployment options depending on your requirements and preferred tooling.

## Folder Structure

```
├── CloudFormation      # AWS CloudFormation templates
├── Terraform           # HashiCorp Terraform configurations
├── Pulumi              # Pulumi programs (multi-cloud)
```

## Tools

### CloudFormation
AWS-native service for modeling and provisioning AWS resources. Templates are written in YAML or JSON.

### Terraform
HashiCorp's multi-cloud IaC tool using declarative configuration language (HCL).

### Pulumi
Multi-cloud IaC using general-purpose programming languages (Python, JavaScript, TypeScript, Go, etc.).

## Getting Started

### Prerequisites
- AWS CLI configured
- Terraform CLI installed
- Pulumi CLI installed
- Python 3.x

### Usage Examples

#### CloudFormation
```bash
aws cloudformation deploy --template-file ./CloudFormation/example.yaml --stack-name my-stack
```

#### Terraform
```bash
cd Terraform
terraform init
terraform plan
terraform apply
```

#### Pulumi
```bash
cd Pulumi
pulumi up
```

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
