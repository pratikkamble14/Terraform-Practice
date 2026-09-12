# Terraform-Practice

This repository is for learning and demonstration purposes. It contains Terraform configuration files to create an EC2 instance on AWS.

## Prerequisites

- Terraform >= 1.5.0
- AWS account with credentials
- AWS CLI configured (`aws configure`)
- SSH key pair for EC2 instance access

## Project Structure

| File / Directory | Purpose |
|------------------|---------|
| **`provider.tf`** | AWS Provider configuration - defines the cloud provider (AWS), region, and provider version required for the configuration |
| **`ec2.tf`** | EC2 instance resource - creates the actual EC2 instance with AMI, instance type, subnet, and tags |
| **`terraform.tf`** | Backend/Required providers configuration - manages state storage and provider version requirements |
| **`terraform.tfstate`** | Current state file - Terraform automatically generates this after `apply`; maps real infrastructure to configuration |
| **`terraform.tfstate.backup`** | State backup - safety net created before destructive operations; allows recovery if state gets corrupted |
| **`.terraform/`** | Provider plugins directory - automatically created by `terraform init`; contains downloaded provider binaries |
| **`terraform-key-ec2` / `terraform-key-ec2.pub`** | SSH key pair - private key stays local; public key is embedded in the EC2 instance for SSH access |
| **`tf/` directory** | Organized Terraform files - logical separation of concerns (provider and resources kept separate for maintainability) |

## Getting Started

```bash
# Initialize Terraform and download providers
terraform init

# Review what will be created
terraform plan

# Apply the configuration to create the EC2 instance
terraform apply

# Destroy the infrastructure when finished
terraform destroy
```

## Important Notes

- This is for learning and demo purposes only
- Never commit `terraform.tfstate` or private keys to version control
- The SSH key (`terraform-key-ec2`) is used to access the EC2 instance after it's created
- State files should be managed carefully; consider using remote backends for team collaboration