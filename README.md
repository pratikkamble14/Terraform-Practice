# Terraform-Practice

**Learning and demonstration repository for Terraform best practices.**

This repository contains two Terraform configurations:
- `tf/` - Local EC2 deployment with nginx
- `remote-infra/` - Remote state backend using S3

---

## 📁 Directory Structure

```
Terraform-Practice/
├── .gitignore           # Excludes .terraform/, state files, keys, logs
├── README.md            # This documentation
├── tf/                  # LOCAL TERRAFORM CONFIGURATION
│   ├── provider.tf      # AWS provider (ap-south-1)
│   ├── ec2.tf           # Core resources (key, VPC, SG, EC2 instances)
│   ├── variables.tf     # Input variables with defaults
│   ├── terraform.tf     # Required providers + S3 backend config
│   ├── outputs.tf       # Public IPs output (for_each)
│   ├── install_nginx.sh # Shell script (installs + configures nginx)
│   └── terraform.tfstate*  # Local state (excluded by .gitignore)
└── remote-infra/        # REMOTE STATE BACKEND CONFIGURATION
    ├── providers.tf     # AWS provider (ap-south-1)
    ├── s3.tf            # S3 bucket "pk-terraf-state-bucket" for remote state
    ├── terraform.tf    # Required providers config (minimal)
    └── terraform.tfstate  # Remote state stored in S3 (locked via use_lockfile)
```

---

## ⚠️ Prerequisites

### AWS CLI Configuration
```bash
aws configure
# Requires IAM permissions for: ec2, s3, iam resources
```

### Tools
- **Terraform** v1.0+ (download: https://developer.hashicorp.com/terraform/downloads)
- **AWS CLI** configured with credentials

### Existing Infrastructure
- SSH key pair already present at `tf/terraform-key-ec2` + `tf/terraform-key-ec2.pub`
- **Or** create new key pair:
  ```bash
  ssh-keygen -t rsa -b 2048 -f terraform-key-ec2
  ```
- S3 bucket `pk-terraf-state-bucket` (created via `remote-infra/s3.tf` if needed)

---

## 🚀 Local Execution (`tf/` directory)

### Step 1: Initialize Terraform
```bash
cd tf
terraform init
# - Initializes provider hashicorp/aws ~> 6.0
# - Configures backend "s3" (if using remote state)
# - Downloads plugins into .terraform/
```

### Step 2: Review Planned Changes
```bash
terraform plan
# Verifies:
# - Key pair creation/import
# - Default VPC + Security Group (SSH:22, HTTP:80, HTTPS:443, Custom:8000 from 0.0.0.0/0)
# - 3 EC2 instances (t3.micro, t3.small, t3.micro) via for_each
# - Nginx installation via user_data
# - Root block device (15GB gp3 default)
```

### Step 3: Apply Configuration
```bash
terraform apply
# Creates:
# 1. aws_key_pair.my-key
# 2. aws_default_vpc.default
# 3. aws_security_group.my-sg (5 ingress + 1 egress rule)
# 4. 3 EC2 instances via for_each (t3.micro/small)
# 5. user_data runs install_nginx.sh on each instance
# 6. Outputs: Array of public IPs
```

### Step 4: Access the Application
```bash
# After apply completes, outputs show:
# aws_instance = [
#   "http://<public-ip-1>/",  # t3.micro
#   "http://<public-ip-2>/",  # t3.small
#   "http://<public-ip-3>/"]  # t3.micro

# Visit in browser: http://<public-ip>/
# Displays: "Terraform is Running and also Nginx on EC2 and this is my GitHub: Click Me"
```

### Step 5: Verify Nginx
```bash
# SSH into instance
ssh -i terraform-key-ec2 ec2-user@<public-ip>

# Check nginx status
sudo systemctl status nginx

# View custom HTML
cat /var/www/html/index.html
# Shows custom page with GitHub link to https://github.com/pratikkamble14/
```

---

## 🌐 Variable Management

### Default Variables (`variables.tf`)
| Variable | Type | Default | Description |
|---|---|---|---|
| `ec2_instance` | string | "t3.micro" | Base instance type |
| `ec2_root_storage_size` | number | 15 | Root volume size (GB) |
| `ec2_ami_id` | string | "ami-01a00762f46d584a1" | Ubuntu AMI ID (ap-south-1) |

### Override Variables

**Command line:**
```bash
terraform apply -var "ec2_instance=t3.small"
```

**Via tfvars file** (create `myvars.tfvars`):
```hcl
ec2_instance = "t3.large"
ec2_root_storage_size = 50
```

Apply with:
```bash
terraform apply -var-file="myvars.tfvars"
```

---

## 🏢 Remote State Backend (`remote-infra/`)

### Purpose
- Enables team collaboration with centralized state
- Provides state locking to prevent concurrent operations
- Acts as source of truth for infrastructure

### Initial Setup
```bash
cd remote-infra
terraform init          # Configures S3 backend
terraform apply         # Creates S3 bucket "pk-terraf-state-bucket"

# Subsequent runs from any machine:
cd tf
terraform init          # Uses remote backend
# Or specify explicitly:
terraform init -backend-config="bucket=pk-terraf-state-bucket" \
               -backend-config="key=terraform.tfstate" \
               -backend-config="region=ap-south-1"
```

### State Workflow with Remote Backend
```bash
# View remote state
terraform show

# Refresh state from remote
terraform refresh

# All operations read/write to S3 backend
terraform plan
terraform apply
terraform destroy
```

---

## 🗑️ Cleanup / Teardown

```bash
# Destroy all created resources
terraform destroy

# Resources removed:
# - aws_key_pair.my-key
# - aws_default_vpc.default
# - aws_security_group.my-sg
# - 3 aws_instance (t3.micro/small)
# - Associated ENIs, volumes, IPs

# State file remains (for future reference)
# To fully remove: rm terraform.tfstate*
```

---

## 📋 Execution Workflow Summary

```
┌─────────────┐     ┌────────────────────┐     ┌─────────────────────┐
│ 1. cd tf     │ →   │ 2. terraform init  │ →   │ 3. terraform plan   │
│ (local cfg)  │     │ (providers + backend)│   │ (review changes)    │
└─────────────┘     └────────────────────┘     └─────────────────────┘
       │                                                 │
       ▼                                                 ▼
┌─────────────────────┐                    ┌──────────────────────┐
│ 4. terraform apply  │ → → → → → → → → │ Resources created    │
│ (provision EC2 etc) │                    │ (key, vpc, sg, inst) │
└─────────────────────┘                    └──────────────────────┘
       │                                                 │
       ▼                                                 ▼
┌─────────────────────┐     ┌────────────────────┐
│ 5. Access via HTTP  │     │ 6. terraform destroy│
│ http://<ip>/        │ →   │ (cleanup all)      │
└─────────────────────┘     └────────────────────┘
```

---

## 🔑 Key Project Notes

### Security Considerations
- **`.gitignore` excludes**: `.terraform/`, `terraform.tfstate*`, `*.tfvars`, SSH keys
- Security groups allow broad access (`0.0.0.0/0`) for demo - restrict in production
- SSH key pair stored locally - never commit to version control
- Nginx HTML contains GitHub link - customize as needed

### Terraform Version Compatibility
- Provider version: `~> 6.0` (supports Terraform 1.0+)
- Backend: S3 with implicit DynamoDB locking (`use_lockfile = true`)
- AMI `ami-01a00762f46d584a1` is Ubuntu 20.04 in `ap-south-1`

### ForEach Usage
- EC2 instances use `for_each = tomap({PK = "t3.micro", KP = "t3.small", automate-pk-micro = "t3.micro"})`
- Outputs iterate: `for i in aws_instance.my_instance : i.public_ip`
- Tags per instance: `Name = each.key`

### Customization Points
1. **Instance types**: Modify `for_each` map in `ec2.tf`
2. **AMI**: Update `var.ec2_ami_id` or pass via `-var`
3. **Storage**: Change `ec2_root_storage_size` default or override at apply time
4. **Security**: Restrict `cidr_blocks` in security group ingress rules
5. **Nginx HTML**: Edit `install_nginx.sh` template

---

## 🛠️ Troubleshooting

### Common Issues

**1. Backend config error**
```
Error: Failed to configure backend
```
→ Re-run `terraform init` or verify S3 bucket exists with correct permissions.

**2. Key pair already exists**
```
Error: Key pair already exists
```
→ Import existing key: `aws ec2 import-key-pair --key-name terraform-key-ec2 --public-key-file tf/terraform-key-ec2.pub`

**3. State locking error**
```
Error: Error acquiring the lock
```
→ Another Terraform process may be running. Wait or use `-lock-timeout=30s`.

**4. Nginx not accessible**
→ Verify security group allows HTTP (80) from `0.0.0.0/0`
→ SSH into instance and check: `sudo systemctl status nginx`