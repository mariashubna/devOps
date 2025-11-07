# Terraform Project: lesson-5

## Description

This project demonstrates how to use Terraform to deploy AWS infrastructure with centralized state management in S3 and state locking using DynamoDB.

The project includes modules for:

- **S3 and DynamoDB** — Terraform state storage and lock table.
- **VPC** — Creation of a VPC with public and private subnets, Internet Gateway, and NAT Gateway.
- **ECR** — Repository for storing Docker images.

---

## Project Structure

lesson-5/
│
├── main.tf # Module declarations
├── backend.tf # Backend configuration (S3 + DynamoDB)
├── outputs.tf # Outputs of resources
├── variables.tf # Global variables
├── README.md # Project documentation
│
└── modules/
├── s3-backend/
├── vpc/
└── ecr/

---

## Modules

### s3-backend

- Creates an S3 bucket for storing Terraform state.
- Enables versioning for state history.
- Creates a DynamoDB table for state locking.
- **Outputs**: `s3_bucket_name`, `dynamodb_table_name`.

### vpc

- Creates a VPC with a specified CIDR block.
- Creates 3 public and 3 private subnets.
- Creates an Internet Gateway and NAT Gateway.
- Configures routing via Route Tables.
- **Outputs**: `vpc_id`.

### ecr

- Creates an ECR repository for Docker images.
- Enables automated image scanning.
- **Outputs**: `ecr_repository_url`.

---

## Usage

> **Important:** If this is your first run, **temporarily comment out the backend block** in `backend.tf` to create the S3 bucket and DynamoDB table. After the S3 bucket and DynamoDB table exist, uncomment the backend block and run `terraform init -reconfigure`.

1. **Initialize Terraform without backend (first run):**

```bash
terraform init
```

2. **Preview changes:**

```bash
terraform plan
```

3. **Apply infrastructure:**

```bash
terraform apply
```

4. **Import existing resources if needed (e.g., S3 bucket, DynamoDB table):**

```bash
terraform import module.s3_backend.aws_s3_bucket.terraform_state <bucket-name>
terraform import module.s3_backend.aws_dynamodb_table.terraform_locks <table-name>
```

5. **Uncomment backend and reconfigure:**

```bash
terraform init -reconfigure
```

6. **Continue managing infrastructure:**

```bash
terraform plan
terraform apply
```

7. **Destroy resources:**

```bash
terraform destroy
```

## Variables

All variables are defined in variables.tf and within modules. Examples:

- bucket_name — name of the S3 bucket for Terraform state.

- table_name — name of the DynamoDB lock table.

- vpc_cidr_block — CIDR block for the VPC.

- public_subnets and private_subnets — lists of subnet CIDRs.

## Outputs

After terraform apply, the following outputs are available:

- s3_bucket_name — name of the S3 bucket.

- dynamodb_table_name — name of the DynamoDB table.

- vpc_id — ID of the created VPC.

- ecr_repository_url — URL of the ECR repository.
