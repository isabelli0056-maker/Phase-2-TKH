# Keyless DevSecOps Terraform Pipeline & Hardened S3 Deployment

This project demonstrates an enterprise-grade DevSecOps pipeline using GitHub Actions to audit, plan, and deploy secure AWS infrastructure without static access keys. By combining keyless OpenID Connect (OIDC) authentication, static Application Security Testing (SAST) via tfsec, and automated Terraform provisioning, this repository establishes an immutable, highly secured AWS S3 storage baseline.

## Technologies Used

* **Cloud & Infrastructure:** AWS (S3, IAM OIDC Federation), HashiCorp Terraform (HCL)
* **DevSecOps & CI/CD:** GitHub Actions, OpenID Connect (OIDC) Keyless Authentication
* **Security & Compliance:** tfsec SAST Scanner, AWS S3 Public Access Block, AES256 Encryption, Versioning

---

### Pipeline Architecture & Workflow

* **Step 1: Security Gate:** Automated SAST Scan via tfsec
* **Step 2: Terraform Plan:** Infrastructure Validation & Drift Check
* **Step 3: Keyless Deploy:** AWS Authentication via OIDC driving automated S3 provisioning

---

### Key Security & Architecture Features

* **Keyless Identity Security (OIDC):** Replaces static credentials with dynamic, short-lived Web Identity Tokens via OpenID Connect to eliminate risk of leaked secrets.
* **Automated Security Quality Gate:** Enforces tfsec static code analysis inside GitHub Actions to intercept misconfigurations prior to deployment.
* **Hardened S3 Infrastructure:** Enforces AES256 server-side encryption, versioning against accidental loss or ransomware, and strict public access blocks.
