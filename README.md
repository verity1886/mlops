# Terraform Infrastructure Project

This project provides a complete AWS infrastructure setup using Terraform, including VPC, EKS cluster, and supporting resources.

## Prerequisites

### Required Software
- **Terraform**: Version 1.5.0 or later (1.13.0 used)
- **AWS CLI**: Configured with appropriate credentials
- **kubectl**: For managing EKS cluster (optional, for post-deployment)

### AWS Requirements
- AWS account with appropriate permissions
- S3 bucket for storing Terraform state files called vp-test-tf-states (replace accordingly)
- AWS profile configured (default: `ecr-user`)

### Required IAM Policies
The following AWS managed policies should be attached to the IAM user/role used for Terraform deployment:

**AWS Managed Policies:**
- `AmazonEC2ContainerRegistryFullAccess` - Full access to ECR
- `AmazonEC2FullAccess` - Full access to EC2 services
- `AmazonEKS_CNI_Policy` - EKS CNI policy for networking
- `AmazonEKSClusterPolicy` - EKS cluster management
- `AmazonEKSWorkerNodePolicy` - EKS worker node management
- `AmazonS3FullAccess` - Full access to S3 (for state management)
- `AmazonVPCFullAccess` - Full access to VPC services
- `AWSKeyManagementServicePowerUser` - KMS key management
- `CloudWatchFullAccess` - Full access to CloudWatch
- `IAMFullAccess` - Full access to IAM services

**Custom Policy:**
```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "EKSFullAccess",
			"Effect": "Allow",
			"Action": "eks:*",
			"Resource": "*"
		},
		{
			"Sid": "IAMPermissionsForRoles",
			"Effect": "Allow",
			"Action": [
				"iam:CreateRole",
				"iam:DeleteRole",
				"iam:GetRole",
				"iam:TagRole",
				"iam:UntagRole",
				"iam:AttachRolePolicy",
				"iam:DetachRolePolicy",
				"iam:ListAttachedRolePolicies",
				"iam:PassRole"
			],
			"Resource": "arn:aws:iam::428635019594:role/*"
		},
		{
			"Sid": "IAMServiceLinkedRolePermissions",
			"Effect": "Allow",
			"Action": "iam:CreateServiceLinkedRole",
			"Resource": "*",
			"Condition": {
				"StringEquals": {
					"iam:AWSServiceName": [
						"eks.amazonaws.com",
						"ec2.amazonaws.com",
						"elasticloadbalancing.amazonaws.com",
						"autoscaling.amazonaws.com",
						"spot.amazonaws.com",
						"vpc-cni.amazonaws.com"
					]
				}
			}
		},
		{
			"Sid": "EC2AndVPCPermissions",
			"Effect": "Allow",
			"Action": [
				"ec2:Describe*",
				"ec2:RunInstances",
				"ec2:TerminateInstances",
				"ec2:CreateTags",
				"ec2:DeleteTags",
				"ec2:CreateSecurityGroup",
				"ec2:DeleteSecurityGroup",
				"ec2:AuthorizeSecurityGroupIngress",
				"ec2:RevokeSecurityGroupIngress"
			],
			"Resource": "*"
		},
		{
			"Sid": "SSMAndKMSPermissions",
			"Effect": "Allow",
			"Action": [
				"ssm:GetParameter",
				"kms:CreateGrant",
				"kms:DescribeKey"
			],
			"Resource": "*"
		}
	]
}
```

> **Note:** These policies provide broad permissions that are required for the infrastructure deployment. While some permissions may seem excessive, they are necessary for Terraform to create and manage the VPC, EKS cluster, and associated resources. In production environments, consider creating more restrictive custom policies based on your specific security requirements.

## Usage

### Initial Setup

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```
4. **Check nodes**:
	```bash
	aws eks --region us-east-1  update-kubeconfig --name myproject-eks
	kubectl get nodes
	```

#### ArgoCD setup
1. **Setup argocd**:
   ```bash
   cd argocd && terraform apply
   ```
2. **Forward ports**:
   ```bash
    kubectl -n infra-tools port-forward svc/argocd-server 8080:443
   ```

3. **Get password for ArgoCD UI**:
   ```bash
    kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
   ```
   
4. **Check https://localhost:8080**.
Login as admin with password from the step 3


#### Run MLFlow with ArgoCD
1. **Create application.yaml:**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mlflow
  namespace: infra-tools
spec:
  project: default
  source:
    repoURL: https://github.com/verity1886/mlflow-rep.git
    targetRevision: main
    path: charts/mlflow
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: mlflow
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```
2. **Run this file:**
	```bash
	kubectl apply -f application.yaml
	```
    **MLFlow should appear as ArgoCD Application with Healthy state.**
3. **Ceck mlflow pod to be RUNNING:**
	```bash
	kubectl get pods -n mlflow
	```
4. **Forward ports:**
	```bash
	kubectl port-forward svc/mlflow -n mlflow 5000:5000
	```
5. **Check https://localhost:5000**:


### Destroy Infrastructure

#### Destroy All Resources
```bash
terraform destroy
```
