provider "aws" {
  region = "eu-central-1"
}

# -------------------------
# S3 Backend
# -------------------------
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "terraform-state-bucket-001001-maria-sv-eu"
  table_name  = "terraform-locks"
}

# -------------------------
# VPC
# -------------------------
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"

  # Подсети (по 3 public и 3 private)
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  # Доступные зоны в регионе eu-central-1
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  vpc_name           = "lesson-8-9-vpc"
}

# -------------------------
# ECR
# -------------------------
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-8-9-ecr"
  scan_on_push = true
}

# -------------------------
# EKS
# -------------------------
module "eks" {
  source       = "./modules/eks"
  cluster_name = "lesson-8-9-cluster"
  subnet_ids   = module.vpc.private_subnet_ids
}

# -------------------------
# ArgoCD
# -------------------------
module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
  depends_on    = [module.eks]
}

# -------------------------
# EKS Data Sources
# -------------------------
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

# -------------------------
# Kubernetes Provider
# -------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

# -------------------------
# Helm provider (если нужен)
# -------------------------
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}