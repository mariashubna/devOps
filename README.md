# Terraform & Kubernetes Project: lesson-5 / lesson-7

## Description

This project demonstrates how to deploy AWS infrastructure using Terraform, manage state centrally in S3 with DynamoDB for locking, and deploy a Django application on Kubernetes (EKS) using Helm.

---

## Project Goals

1. Deploy AWS infrastructure with Terraform:
   - S3 bucket for Terraform state.
   - DynamoDB table for state locking.
   - VPC with public and private subnets, Internet Gateway, and NAT Gateway.
   - ECR repository for Docker images.
2. Deploy a Kubernetes cluster (EKS) in the same VPC.
3. Build and push Django Docker image to ECR.
4. Deploy Django app using Helm with:
   - Deployment
   - Service (LoadBalancer)
   - Horizontal Pod Autoscaler (HPA)
   - ConfigMap for environment variables
   - Optional Ingress with TLS support and cert-manager.

---

## Project Structure

lesson-7/
│
├── main.tf — Terraform main file for module integration
├── backend.tf — Backend configuration for state (S3 + DynamoDB)
├── outputs.tf — Terraform outputs (VPC ID, ECR URL, etc.)
├── variables.tf — Global variables
├── README.md — Project documentation
├── modules/
│ ├── s3-backend/
│ ├── vpc/
│ ├── ecr/
│ └── eks/ — Module for Kubernetes cluster (EKS)
└── charts/
└── django-app/ — Helm chart for Django deployment
├── templates/
│ ├── deployment.yaml
│ ├── service.yaml
│ ├── configmap.yaml
│ ├── hpa.yaml
│ └── ingress.yaml (optional)
├── Chart.yaml
└── values.yaml

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

### eks

- Creates EKS cluster.
- Attaches node groups to private subnets.
- **Outputs**: `cluster_name`, `cluster_endpoint`.

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

## Docker & ECR

**Build Docker image for Django:**

```bash
docker build -t lesson-5-ecr .
```

**Authenticate Docker with ECR:**

```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-west-2.amazonaws.com
```

**Tag and push image:**

```bash
docker tag lesson-5-ecr:latest <account_id>.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest
docker push <account_id>.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest
```

## Helm Deployment (Django)

**Deploy with Helm**

```bash
helm upgrade --install django-app ./charts/django-app
```

**Verify Deployment**

```bash
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get hpa
kubectl get configmap
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
