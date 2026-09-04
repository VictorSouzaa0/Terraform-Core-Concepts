# 🌍 Learning Terraform on AWS

Personal notes and hands-on practice repo for learning **Infrastructure as Code (IaC)** with **Terraform** on **AWS**. I'm building this as I go through my course, so it also works as a reference for myself later — and as proof of hands-on learning for interviews.

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)

---

## 📋 Table of Contents

- [About](#about)
- [Prerequisites](#prerequisites)
- [Installing Terraform (Windows)](#installing-terraform-windows)
- [Configuring AWS Credentials](#configuring-aws-credentials)
- [Terraform Core Workflow](#terraform-core-workflow)
- [Project Structure](#project-structure)
- [What NOT to Commit](#-what-not-to-commit)
- [Useful Resources](#useful-resources)
- [Notes / Lessons Learned](#notes--lessons-learned)

---

## About

Terraform is a tool by HashiCorp that lets you define cloud infrastructure (servers, networks, storage, etc.) as code, in `.tf` files, instead of clicking around in the AWS Console. This repo tracks what I'm learning: installation, AWS setup, and the core commands that make up the day-to-day Terraform workflow.

---

## Prerequisites

- An **AWS account**
- An **IAM user** with programmatic access (Access Key ID + Secret Access Key) — avoid using your AWS root account for daily work
- **AWS CLI** installed
- **Terraform** installed
- (Optional but recommended) [VS Code](https://code.visualstudio.com/) with the official [HashiCorp Terraform extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)

---

## Installing Terraform (Windows)

### Option 1 — Using Chocolatey (recommended)

If you have [Chocolatey](https://chocolatey.org/install) installed:

```powershell
choco install terraform
```

### Option 2 — Manual install

1. Download the Windows binary from the [official Terraform downloads page](https://developer.hashicorp.com/terraform/downloads)
2. Extract the `.zip` file (it contains a single `terraform.exe`)
3. Move `terraform.exe` to a folder, e.g. `C:\terraform`
4. Add that folder to your **PATH** environment variable (System Properties → Environment Variables → Path → New)
5. Open a new terminal and verify:

```powershell
terraform -version
```

You'll also need the **AWS CLI** installed — download it from [AWS's official page](https://aws.amazon.com/cli/) and verify with:

```powershell
aws --version
```

---

## Configuring AWS Credentials

Terraform's AWS provider needs valid credentials to talk to your AWS account. The simplest way is through the AWS CLI:

```powershell
aws configure
```

You'll be prompted for:

| Prompt | Example |
|---|---|
| AWS Access Key ID | `AKIA...` |
| AWS Secret Access Key | `wJalrXUtnFEMI...` |
| Default region name | `us-east-1` |
| Default output format | `json` |

This saves your credentials locally (in `~/.aws/credentials` on Windows: `C:\Users\<you>\.aws\credentials`), and Terraform will automatically pick them up.

> ⚠️ **Never commit these credentials to Git.** Create an IAM user with only the permissions you need, and rotate/delete keys you're not using.

---

## Terraform Core Workflow

| Command | Purpose |
|---|---|
| `terraform init` | Initializes the working directory and **downloads the provider plugins** (e.g. the AWS provider) declared in your `.tf` files. Run this first, and again whenever you add/change providers or modules. |
| `terraform validate` | Checks that your configuration files are syntactically valid. |
| `terraform fmt` | Auto-formats your `.tf` files to the standard style. |
| `terraform plan` | Creates an **execution plan** — a dry run showing exactly what Terraform *would* create, change, or destroy, without touching real infrastructure. |
| `terraform apply` | Executes the plan and actually **creates/modifies** the resources in AWS. |
| `terraform destroy` | Tears down all resources managed by the configuration — important for avoiding unexpected AWS costs while learning. |

### Typical order of commands

```powershell
terraform init      # download providers & set up the working dir
terraform validate  # (optional) sanity-check the code
terraform fmt        # (optional) tidy up formatting
terraform plan       # preview what will happen
terraform apply      # apply changes for real
terraform destroy    # clean up when you're done experimenting
```

---

## Project Structure

```
.
├── main.tf          # main resources
├── variables.tf      # input variable declarations
├── outputs.tf         # output values
├── terraform.tfvars   # variable values (never commit secrets here!)
├── .gitignore
└── README.md
```

---

## 🚫 What NOT to Commit

Terraform generates local files that should **never** go into version control — they can contain secrets or are just machine-specific. Add this `.gitignore`:

```gitignore
# Local .terraform directories
**/.terraform/*

# State files (can contain sensitive data)
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Variable files that may contain secrets
*.tfvars
*.tfvars.json

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI configuration files
.terraformrc
terraform.rc
```

---

## Useful Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [HashiCorp Learn — Terraform Tutorials](https://developer.hashicorp.com/terraform/tutorials)

---

## Notes / Lessons Learned

*(A place to jot down anything that tripped you up or clicked for you — great material to talk about in interviews.)*

- 
- 
- 
