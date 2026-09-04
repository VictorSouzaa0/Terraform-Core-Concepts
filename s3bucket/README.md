# 🪣 Amazon S3 with Terraform

Notes on the first "real" resource in this repo: an S3 bucket, created and destroyed
with Terraform instead of clicking around the AWS Console. This file explains the
**concepts** behind `main.tf` in this folder, not just the commands.

---

## 📋 Table of Contents

- [What problem does S3 solve?](#what-problem-does-s3-solve)
- [Breaking down `main.tf`](#breaking-down-maintf)
- [Bucket naming rules (the part that trips people up)](#bucket-naming-rules-the-part-that-trips-people-up)
- [Files Terraform creates in this folder](#files-terraform-creates-in-this-folder)
- [Workflow: init → plan → apply → destroy](#workflow-init--plan--apply--destroy)
- [Common pitfalls](#common-pitfalls)
- [Why this matters (Well-Architected)](#why-this-matters-well-architected)
- [Quick self-check](#quick-self-check)

---

## What problem does S3 solve?

Before Terraform, before even AWS: applications need somewhere to put files —
images, backups, logs, static website assets, video, whatever — that isn't tied to a
single server's disk. If the server dies or you scale to ten servers, a local disk
doesn't work anymore.

**Amazon S3 (Simple Storage Service)** is object storage: you throw files ("objects")
into a container (a "bucket") over HTTPS/API, and AWS handles durability, availability,
and scaling for you. You don't manage disks, RAID, or capacity — you just PUT and GET
objects. That's the core idea: storage as a service, decoupled from any single machine.

It's not a filesystem and it's not a database — it's closer to a giant, extremely
durable key-value store where the key is the object's path and the value is the file
itself.

---

## Breaking down `main.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create S3 Bucket
resource "aws_s3_bucket" "first-bucket" {
  bucket = "victorsouza-20050948-bucket"

  tags = {
    Name        = "My bucket 2.0"
    Enviroment  = "Dev"
  }
}
```

| Block | What it means |
|---|---|
| `terraform { required_providers { ... } }` | Tells Terraform which plugin (provider) to download so it can talk to AWS's API, and pins a version range (`~> 6.0` = any 6.x, but not 7.0) so the same code behaves the same way later. |
| `provider "aws" { region = ... }` | Configures *where* resources get created. S3 buckets are technically global by name, but the bucket still has a "home" region — this is it. |
| `resource "aws_s3_bucket" "first-bucket" { ... }` | The actual declaration: "I want a bucket to exist." `aws_s3_bucket` is the resource **type** (defined by the AWS provider), `first-bucket` is the local Terraform **name** you use to refer to it elsewhere in your code — it is *not* the bucket's real name in AWS. |
| `bucket = "..."` | The real, global name of the bucket in AWS. |
| `tags = { ... }` | Metadata key/value pairs. Doesn't change how the bucket behaves, but it's how you track cost, ownership, and environment at scale (imagine 200 buckets across a company — tags are how you find "which ones are Dev and can be deleted"). |

---

## Bucket naming rules (the part that trips people up)

S3 bucket names are **globally unique across all of AWS**, not just unique in your
account. That's why this project's bucket name has your username and a number baked in
(`victorsouza-20050948-bucket`) — `my-bucket` was almost certainly taken by someone else
years ago.

Other rules worth knowing:

- 3–63 characters, lowercase letters, numbers, dots and hyphens only.
- Can't look like an IP address (`192.168.1.1`).
- Renaming a bucket isn't a thing — you create a new one and migrate objects.

---

## Files Terraform creates in this folder

| File | What it is | Commit to Git? |
|---|---|---|
| `.terraform/` | Downloaded provider plugin binaries (the AWS provider). Machine-specific, safe to regenerate with `terraform init`. | ❌ No |
| `.terraform.lock.hcl` | Locks the exact provider version/checksums so everyone on the team gets the same provider. | ✅ Yes (this one is an exception — it's small and ensures reproducibility) |
| `terraform.tfstate` | Terraform's memory of what it actually created in AWS (bucket ARN, ID, current tags, etc.). Terraform diffs your `.tf` code against this file to know what changed. | ❌ No — can contain sensitive data and causes conflicts if multiple people edit it |
| `terraform.tfstate.backup` | Automatic backup of the previous state, written before each state update. | ❌ No |

This matches the root [`README.md`](../README.md#-what-not-to-commit) `.gitignore` rules — state files and the `.terraform` folder should never be pushed.

---

## Workflow: init → plan → apply → destroy

Same four commands from the root README, applied to this specific bucket:

```powershell
terraform init      # downloads the AWS provider into .terraform/
terraform plan       # shows: "+ aws_s3_bucket.first-bucket will be created"
terraform apply      # actually calls the AWS API and creates the bucket
terraform destroy    # deletes the bucket from AWS
```

What actually happens under the hood:

1. **`init`** reads `required_providers`, downloads the `hashicorp/aws` plugin that
   knows how to translate `resource "aws_s3_bucket"` into real AWS API calls
   (`CreateBucket`, `PutBucketTagging`, etc.).
2. **`plan`** compares your `.tf` code to `terraform.tfstate` (or to "nothing exists
   yet" the first time) and prints a diff — nothing touches AWS yet.
3. **`apply`** executes that diff for real, then writes the result into
   `terraform.tfstate` so Terraform now "remembers" the bucket exists.
4. **`destroy`** looks at `terraform.tfstate` to find exactly what it created, and
   deletes it — this is what keeps a learning/practice account from quietly
   racking up AWS charges.

---

## Common pitfalls

- **"BucketAlreadyExists" on `apply`** → someone else already owns that global name.
  Change `bucket = "..."` to something more unique and re-run `plan`/`apply`.
- **`destroy` fails on a non-empty bucket** → by default S3 won't let you delete a
  bucket that still has objects in it. You'd either empty it manually/via CLI first, or
  add `force_destroy = true` to the resource (useful for throwaway learning buckets,
  dangerous on anything real).
- **Region confusion** → the bucket "lives" in `us-east-1` here because that's what the
  `provider` block says, not because S3 is regionless. Buckets in other regions need a
  matching `provider` (or explicit region config) or Terraform/AWS will complain.

---

## Why this matters (Well-Architected)

This maps most directly to the **Cost Optimization** and **Sustainability** pillars:
running `terraform destroy` after a practice session is exactly the discipline that
keeps an idle bucket, an idle EC2 instance, or an idle RDS database from silently
generating a bill for a company for weeks after someone stopped using it. At small
scale it's cents; at the scale of a real company with hundreds of forgotten dev/test
resources, "nobody remembered to tear it down" is one of the most common ways cloud
bills balloon.

Tags also connect to **Operational Excellence** — without a `Name`/`Enviroment` tag
convention, a finance or ops team looking at an AWS bill with 500 buckets has no way to
tell which ones are safe to delete.


