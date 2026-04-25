# CuliShop Infrastructure

Terraform infrastructure as code for CuliShop — a microservices e-commerce platform running on AWS ECS Fargate in the `ap-southeast-1` region.

This repo provisions:

- **VPC** — 3-tier, multi-AZ networking with security groups
- **ECR** — Container image repositories for each service
- **ECS** — Fargate Spot cluster with 13 services connected via Service Connect
- **ALB** — Application Load Balancer with path-based routing
- **IAM** — Task execution and task roles for ECS
- **Aurora MySQL** — Managed MySQL database (toggle: `enable_aurora`)
- **ElastiCache Redis** — Managed Redis cache (toggle: `enable_elasticache`)
- **KMS** — Encryption key for sops secrets management (toggle: `enable_kms_sops`)
- **Bastion** — EC2 bastion host for private subnet access (lab sessions 09–10)

## Lab Sessions

Each lab session is tagged so you can jump to a specific point in the course:

```bash
# List all lab sessions
git tag -l -n1

# Switch to a specific session
git checkout lab-08
```

| Tag | Topic |
|-----|-------|
| `lab-08` | ALB and Auto Scaling |
| `lab-09` | Aurora MySQL — MySQL ECS off, Redis ECS on |
| `lab-10` | ElastiCache Valkey — MySQL ECS on, Redis ECS off |
| `lab-14` | Terraform Advanced — Aurora + ElastiCache + KMS/sops |

> **Note:** Checking out a tag puts you in "detached HEAD" state — you can explore and run `terraform plan`, but create a branch first if you want to make changes: `git checkout -b my-experiment lab-08`

## Cost Overview

| Resource | Monthly Cost | Toggle | Kept Between Labs? |
|----------|-------------|--------|--------------------|
| VPC, subnets, SGs, IGW | $0 | always on | Yes |
| ECR repos + images | ~$0.20 | always on | Yes (skip rebuild) |
| IAM roles | $0 | always on | Yes |
| ECS cluster (0 tasks) | $0 | always on | Yes |
| **NAT Gateway** | **~$32** | `enable_nat_gateway` | No |
| **ALB** | **~$16** | `enable_alb` | No |
| **ECS tasks (Fargate)** | per-second | `desired_count` | No |
| **Bastion (t3.micro)** | **~$8** | `enable_bastion` | No |
| **Aurora MySQL (db.t3.medium)** | **~$59** | `enable_aurora` | No |
| **ElastiCache (cache.t3.micro)** | **~$12** | `enable_elasticache` | No |
| **KMS key** | **$1** | `enable_kms_sops` | Yes |

**Idle cost when cleaned up properly: ~$1.20/mo** (ECR storage + KMS key)

## First-Time Setup

### Step 1 — Deploy VPC

```bash
cd aws/culiops-sandbox/ap-southeast-1/vpc/lab
terraform init
terraform apply
```

Creates: VPC, 9 subnets (3 AZs x 3 tiers), NAT Gateway, IGW, 3 security groups.

### Step 2 — Deploy Services Infrastructure

```bash
cd services/culishop/lab
terraform init
terraform apply
# enable_alb = true, desired_count = 0 (default)
```

Creates: ECS cluster, ECR repos, IAM roles, ALB + target groups + listener rules, ECS service definitions (0 running tasks).

### Step 3 — Build and Push Docker Images

```bash
# Get ECR registry from terraform outputs
cd services/culishop/lab
ECR_REGISTRY="$(terraform output -raw ecr_registry)"

# Build all images (reactfrontend uses relative URLs by default,
# which works with ALB path-based routing: /api/* -> apiservice)
./scripts/build-push-ecr.sh --registry "$ECR_REGISTRY"
```

To build a single service:

```bash
./scripts/build-push-ecr.sh --registry "$ECR_REGISTRY" --service apiservice
```

### Step 4 — Start ECS Tasks

```bash
# In services/culishop/lab/terraform.tfvars, set:
#   desired_count = 1
terraform apply
```

Access CuliShop at the ALB DNS URL from terraform output.

## Start a Lab Session

If infrastructure was cleaned up from a previous session:

```bash
# Step 1: Enable NAT Gateway
# In vpc/lab/terraform.tfvars: enable_nat_gateway = true
cd aws/culiops-sandbox/ap-southeast-1/vpc/lab
terraform apply

# Step 2: Enable ALB + start ECS tasks
# In services/culishop/lab/terraform.tfvars:
#   enable_alb    = true
#   desired_count = 1
cd services/culishop/lab
terraform apply
```

No need to rebuild Docker images — ECR repos and images are preserved.

## Cleanup After Lab (save ~$48/mo)

```bash
# Step 1: Stop ECS tasks + disable ALB
# In services/culishop/lab/terraform.tfvars:
#   enable_alb    = false
#   desired_count = 0
cd services/culishop/lab
terraform apply

# Step 2: Disable NAT Gateway
# In vpc/lab/terraform.tfvars: enable_nat_gateway = false
cd aws/culiops-sandbox/ap-southeast-1/vpc/lab
terraform apply
```

## Full Teardown

Destroy in reverse order — services depend on VPC resources:

```bash
# 1. Destroy ECS services first
cd services/culishop/lab
terraform destroy

# 2. Then destroy VPC
cd ../../../aws/culiops-sandbox/ap-southeast-1/vpc/lab
terraform destroy
```

## Architecture Overview

### Network

3-tier VPC (`10.0.0.0/16`) across 3 availability zones:

| Tier | Subnets | Internet Access | Purpose |
|------|---------|-----------------|---------|
| Public | 3 x /20 | IGW (bidirectional) | ALB |
| Private-App | 3 x /20 | NAT Gateway (outbound only) | ECS Fargate tasks |
| Private-Data | 3 x /20 | None (fully isolated) | RDS Aurora, ElastiCache |

### Services

ECS Fargate cluster with [Service Connect](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-connect.html) namespace `culishop.local`. Services discover each other via DNS: `<service>.culishop.local:<port>`.

```
Internet
   |
  ALB  (public subnets)
   |--- / ------------> reactfrontend (:80)
   |--- /api/* -------> apiservice (:8090)
                              |
          +-------------------+-------------------+
          |                   |                   |
  productcatalogservice  checkoutservice    cartservicev2   ...
       (:3550)              (:5050)           (:7070)
          |                   |                   |
        mysql (:3306)                        redis (:6379)
```

All 13 services run on **FARGATE_SPOT** in private-app subnets:

| Service | Port | Role | Description |
|---------|------|------|-------------|
| apiservice | 8090 | client | API gateway — routes to downstream services |
| reactfrontend | 80 | client | React SPA frontend |
| productcatalogservice | 3550 | client_server | Product catalog (reads from MySQL) |
| cartservicev2 | 7070 | client_server | Shopping cart (Redis + MySQL) |
| checkoutservice | 5050 | client_server | Checkout orchestrator |
| currencyservice | 7000 | client_server | Currency conversion |
| shippingservice | 50051 | client_server | Shipping cost calculation |
| paymentservice | 50051 | client_server | Payment processing |
| emailservice | 8080 | client_server | Email notifications |
| recommendationservice | 8080 | client_server | Product recommendations |
| adservice | 9555 | client_server | Advertisement service |
| mysql | 3306 | client_server | MySQL 8.0 with baked-in schema and seed data |
| redis | 6379 | client_server | Redis 7 (official alpine image) |

**Service Connect roles:** `client` services only call others. `client_server` services both listen and call.

### ALB Routing

| Path | Target | Port |
|------|--------|------|
| `/api/*` | apiservice | 8090 |
| `/*` (default) | reactfrontend | 80 |

Both target groups use `/healthz` for health checks.

## Repository Structure

```
culishop-infra/
├── aws/culiops-sandbox/ap-southeast-1/
│   └── vpc/lab/                        # VPC root module (Terraform state here)
│
├── services/culishop/
│   └── lab/                            # ECS services root module (Terraform state here)
│       ├── main.tf                     # Provider, remote state for VPC outputs
│       ├── ecr.tf                      # ECR repositories
│       ├── iam.tf                      # ECS IAM roles
│       ├── ecs.tf                      # ECS cluster + 11 app service definitions
│       ├── data-services.tf            # MySQL + Redis service definitions
│       ├── alb.tf                      # ALB, target groups, listener rules
│       ├── bastion.tf                  # Bastion host for database access
│       ├── security.tf                 # Service Connect mesh + ALB SG rules
│       └── outputs.tf                  # Cluster, ECR, networking, ALB outputs
│
├── modules/aws/
│   ├── vpc/                            # 3-tier VPC, NAT Gateway, security groups
│   ├── alb/                            # ALB with path-based routing
│   ├── aurora/                         # Aurora MySQL cluster (Session 09/14)
│   ├── bastion/                        # Bastion host for private subnet access
│   ├── ecr/                            # ECR repos with lifecycle policy (keep last 5)
│   ├── ecs-cluster/                    # Fargate cluster + Service Connect namespace
│   ├── ecs-service/                    # Reusable ECS Fargate service definition
│   ├── elasticache/                    # ElastiCache Redis (Session 10/14)
│   ├── iam-ecs/                        # Task execution role + task role
│   └── kms/                            # KMS key for sops encryption (Session 14)
│
├── scripts/
│   └── build-push-ecr.sh              # Build Docker images and push to ECR
│
└── docker/mysql/
    └── Dockerfile                      # Custom MySQL image with schema + seed data
```

Each root module directory (`vpc/lab/`, `services/culishop/lab/`) is an independent Terraform workspace with its own state file.

## Secrets Management with sops

Use [sops](https://github.com/getsops/sops) + KMS to encrypt `terraform.tfvars` so secrets can be safely committed to Git.

### Setup (one-time)

```bash
# 1. Install sops
brew install sops   # macOS
# or: go install github.com/getsops/sops/v3/cmd/sops@latest

# 2. Deploy KMS key (if not yet created)
cd services/culishop/lab
# Set enable_kms_sops = true in terraform.tfvars
terraform apply

# 3. Get KMS key ARN
KMS_ARN=$(terraform output -raw kms_sops_key_arn)
echo "KMS ARN: $KMS_ARN"
```

### Encrypt secrets

```bash
# Encrypt terraform.tfvars → terraform.tfvars.enc
sops --encrypt --kms arn:aws:kms:ap-southeast-1:226198813800:key/177746f5-5701-4f14-b843-0965e62dc39a terraform.tfvars > terraform.tfvars.enc

# Commit encrypted file (safe!)
git add terraform.tfvars.enc
```

### Decrypt before apply

```bash
# Decrypt → apply → cleanup
sops -d terraform.tfvars.enc > terraform.tfvars
terraform apply
rm terraform.tfvars
```

### `.gitignore` rules

```gitignore
terraform.tfvars       # plain text — NEVER commit
!terraform.tfvars.enc  # encrypted — safe to commit
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with credentials for `culiops-sandbox`
- [Docker](https://docs.docker.com/get-docker/) for building container images
- [sops](https://github.com/getsops/sops) for secrets encryption (optional, Session 14+)
- CuliShop source code at `~/projects/culishop` (override with `--source` flag)

## Naming & Tagging Conventions

### Naming

```
{project}-{environment}-{resource}-{identifier}
```

Examples: `culishop-lab-vpc`, `culishop-lab-sg-alb`, `culishop-lab-alb`

### Required Tags

| Tag | Description | Example |
|-----|-------------|---------|
| Project | Project name | `culishop` |
| Environment | Environment name | `lab` |
| ManagedBy | IaC tool | `Terraform` |
| Tier | Network/resource tier (where applicable) | `public`, `private-app`, `private-data` |
