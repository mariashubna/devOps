# Terraform & Kubernetes Project: lesson-5-7-8-9

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
3. Deploy **Jenkins** using Helm to manage CI pipelines:
   - Build Docker images for Django app.
   - Push images to ECR.
   - Update Helm chart with new image tag.
   - Push changes to Git repository.
4. Deploy **Argo CD** using Helm for GitOps-driven CD:
   - Monitor Helm charts in Git.
   - Automatically synchronize changes to the EKS cluster.
5. Deploy Django application using Helm with:
   - Deployment
   - Service (LoadBalancer)
   - Horizontal Pod Autoscaler (HPA)
   - ConfigMap for environment variables
   - Optional Ingress with TLS support and cert-manager.

---

## Project Structure

lesson-8-9/
Progect/
│
├── main.tf # Головний файл для підключення модулів
├── backend.tf # Налаштування бекенду для стейтів (S3 + DynamoDB
├── outputs.tf # Загальні виводи ресурсів
│
├── modules/ # Каталог з усіма модулями
│ ├── s3-backend/ # Модуль для S3 та DynamoDB
│ │ ├── s3.tf # Створення S3-бакета
│ │ ├── dynamodb.tf # Створення DynamoDB
│ │ ├── variables.tf # Змінні для S3
│ │ └── outputs.tf # Виведення інформації про S3 та DynamoDB
│ │
│ ├── vpc/ # Модуль для VPC
│ │ ├── vpc.tf # Створення VPC, підмереж, Internet Gateway
│ │ ├── routes.tf # Налаштування маршрутизації
│ │ ├── variables.tf # Змінні для VPC
│ │ └── outputs.tf  
│ ├── ecr/ # Модуль для ECR
│ │ ├── ecr.tf # Створення ECR репозиторію
│ │ ├── variables.tf # Змінні для ECR
│ │ └── outputs.tf # Виведення URL репозиторію
│ │
│ ├── eks/ # Модуль для Kubernetes кластера
│ │ ├── eks.tf # Створення кластера
│ │ ├── aws_ebs_csi_driver.tf # Встановлення плагіну csi drive
│ │ ├── variables.tf # Змінні для EKS
│ │ └── outputs.tf # Виведення інформації про кластер
│ ├── rds/ # Модуль для RDS
│ │ ├── rds.tf # Створення RDS бази даних  
│ │ ├── aurora.tf # Створення aurora кластера бази даних  
│ │ ├── shared.tf # Спільні ресурси  
│ │ ├── variables.tf # Змінні (ресурси, креденшели, values)
│ │ └── outputs.tf  
│ │
│ ├── jenkins/ # Модуль для Helm-установки Jenkins
│ │ ├── jenkins.tf # Helm release для Jenkins
│ │ ├── variables.tf # Змінні (ресурси, креденшели, values)
│ │ ├── providers.tf # Оголошення провайдерів
│ │ ├── values.yaml # Конфігурація jenkins
│ │ └── outputs.tf # Виводи (URL, пароль адміністратора)
│ │
│ └── argo_cd/ # ✅ Новий модуль для Helm-установки Argo CD
│ ├── jenkins.tf # Helm release для Jenkins
│ ├── variables.tf # Змінні (версія чарта, namespace, repo URL тощо)
│ ├── providers.tf # Kubernetes+Helm. переносимо з модуля jenkins
│ ├── values.yaml # Кастомна конфігурація Argo CD
│ ├── outputs.tf # Виводи (hostname, initial admin password)
│ └──charts/ # Helm-чарт для створення app'ів
│ ├── Chart.yaml
│ ├── values.yaml # Список applications, repositories
│ └── templates/
│ ├── application.yaml
│ └── repository.yaml
├── charts/
│ └── django-app/
│ ├── templates/
│ │ ├── deployment.yaml
│ │ ├── service.yaml
│ │ ├── configmap.yaml
│ │ └── hpa.yaml
│ ├── Chart.yaml
│ └── values.yaml # ConfigMap зі змінними середовища

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

### jenkins

- Deploys Jenkins via Helm.
- Configures Jenkins service account for Kaniko + Git + AWS integration.
- Prepares pipeline for Docker image build and Helm chart updates.
- **Outputs**: `jenkins_release_name`, `jenkins_namespace`.

### argo_cd

- Deploys Argo CD via Helm.
- Configures Applications and Repositories for GitOps.
- Automatically synchronizes Helm charts from Git to EKS.
- **Outputs**: `namespace`, `argo_cd_server_service`, `admin_password`.

### rds

The module allows you to create:

- Aurora Cluster (PostgreSQL or MySQL)
- Regular RDS instance (PostgreSQL or MySQL)

**Example of use**

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "myapp-db"
  use_aurora = true

  engine                 = "aurora-postgresql"
  engine_version         = "14.11"
  instance_class         = "db.r6g.large"
  parameter_group_family = "aurora-postgresql14"

  aurora_instance_count = 2

  db_name  = "myapp"
  username = "postgres"
  password = "SuperSecretPass123!"
  port     = 5432

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  allowed_cidr_blocks = [
    "10.0.0.0/16"
  ]

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}

```

**RDS module variables**

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

## Jenkins Pipeline

1. Builds Docker image for Django using Kaniko
2. Pushes image to ECR.
3. Updates values.yaml in Helm chart with new image tag.
4. Pushes changes back to Git repository.

Pipeline stages:

1. Prepare: checkout repo, set IMAGE_TAG
2. Build & Push image (Kaniko)
3. Update Helm chart values.yaml
4. Helm lint & template (optional)

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

## Argo CD Deployment

- Monitor Helm chart repository in Git.
- Automatically sync new image tags from Git.

**Access Argo CD UI:**

```bash
kubectl port-forward svc/argo-cd-server -n argocd 8080:443
```

**Admin password:**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
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
