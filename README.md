# ADME (Azure Data Manager for Energy) with Private Endpoint

This repository contains the infrastructure as code (IaC) setup for deploying and managing Azure Data Manager for Energy (ADME) resources with a **Private Endpoint** using Terraform. However, **Terraform does not currently support the management or destruction of ADME resources directly**. As a result, we rely on **Azure Resource Manager (ARM) templates** and Azure CLI commands to handle the deletion of ADME resources.

---

## Overview

Azure Data Manager for Energy (ADME) is a specialized service for managing energy data in Azure. This deployment is specifically designed to provision ADME with a **Private Endpoint**, ensuring secure and private connectivity to the ADME resource.

---

## Key Features

- **Terraform for Infrastructure**:
  - Deploys supporting infrastructure such as resource groups, virtual networks, private endpoints, and DNS zones.
  - Automates the setup of dependencies required for ADME with a Private Endpoint.

- **ARM Templates for ADME**:
  - Used to manage the lifecycle of the ADME resource.

- **Custom Cleanup Logic**:
  - A `null_resource` in Terraform is used to execute Azure CLI commands for cleaning up resources, including private endpoints, DNS zones, and the ADME resource.

- **Private Endpoint Integration**:
  - Ensures secure and private connectivity to the ADME resource by provisioning a Private Endpoint.

---

## Deployment Workflow

1. **Automate with GitHub Actions**:
   - Trigger the GitHub Actions workflow (`terraform.yml`) to deploy the infrastructure.

---

## Destruction Workflow

1. **Automate with GitHub Actions**:
   - Trigger the GitHub Actions workflow (`terraform_destroy.yml`) to destroy the infrastructure.

---

## GitHub Actions Workflows

### **1. Deployment Workflow (`terraform.yml`)**

This workflow automates the deployment of infrastructure using Terraform.

#### Key Steps:
1. **Checkout the Repository**:
   - Uses the `actions/checkout` action to clone the repository to the GitHub Actions runner.

2. **Setup Terraform**:
   - Installs the specified version of Terraform using the `hashicorp/setup-terraform` action.

3. **Terraform Init**:
   - Initializes the Terraform working directory and configures the backend for remote state storage.

4. **Terraform Plan**:
   - Generates an execution plan to show the changes Terraform will make.

5. **Terraform Apply**:
   - Applies the Terraform configuration to deploy the infrastructure.

---

### **2. Destruction Workflow (`terraform_destroy.yml`)**

This workflow automates the destruction of infrastructure using Terraform and Azure CLI.

#### Key Steps:
1. **Checkout the Repository**:
   - Uses the `actions/checkout` action to clone the repository to the GitHub Actions runner.

2. **Setup Terraform**:
   - Installs the specified version of Terraform using the `hashicorp/setup-terraform` action.

3. **Azure CLI Login**:
   - Authenticates with Azure using a service principal.

4. **Terraform Init**:
   - Initializes the Terraform working directory and configures the backend for remote state storage.

5. **Terraform Plan**:
   - Generates a destruction plan to show the resources that will be destroyed.

6. **Destroy ADME Template Resources**:
   - Targets the `null_resource.delete_template_resources` to destroy ADME-related resources.

7. **Destroy All Resources**:
   - Runs `terraform destroy` to remove all remaining resources.

---

## Why ARM Templates for ADME?

Terraform does not currently support the `Microsoft.OpenEnergyPlatform/energyServices` resource type, which is required for managing ADME. This limitation means:
- ADME resources cannot be created, updated, or destroyed directly using Terraform.
- ARM templates or Azure CLI must be used for these operations.

---

## Example Cleanup Script

The repository includes a `null_resource` in Terraform that uses Azure CLI commands to clean up resources during destruction. 