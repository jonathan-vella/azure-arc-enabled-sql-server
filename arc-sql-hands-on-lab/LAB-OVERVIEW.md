# Azure Arc-Enabled SQL Server - Hands-On Lab

Version: v1.2025.12
Last updated: 2025-12-16

A comprehensive hands-on lab for IT Professionals, System Administrators, and Cloud Architects to learn Azure Arc-enabled SQL Server management.

## 📋 Overview

This lab provides end-to-end experience with Azure Arc-enabled SQL Server, covering:

**Core Capabilities:**
- Infrastructure deployment with Bicep
- Server onboarding and SQL discovery
- License management (PAYG & Software Assurance)
- Monitoring and Best Practices Assessment
- Governance at scale with Azure Policy

**Optional Advanced Features (Preview):**
- Automatic Windows and SQL Server updates
- Advanced performance monitoring with DMV metrics
- Automated backups with custom retention policies
- Point-in-time database restores

## 🎯 Prerequisites

**Azure:**
- Active subscription with Owner permissions
- No pre-existing resources required

**On-Premises:**
- Windows Server 2022+ 
- SQL Server 2017+ (Standard/Enterprise) already installed and licensed
- PowerShell 7.0+
- Network connectivity to Azure (HTTPS/443)

## 🚀 Quick Start

For experienced users, see [QUICKSTART.md](QUICKSTART.md) for condensed instructions (~50 minutes).

For detailed step-by-step guidance, see the [full lab guide](README.md).

## 📁 Repository Structure

```
arc-sql-hands-on-lab/
├── README.md                      # Full lab guide (8 modules)
├── QUICKSTART.md                  # Quick start for experienced users
├── bicep/
│   ├── main.bicep                # Main infrastructure template
│   ├── modules/
│   │   └── log-analytics.bicep   # Log Analytics workspace module
│   └── deploy.ps1                # Deployment script
└── scripts/
    ├── Test-ArcConnectivity.ps1  # Network validation script
    └── Cleanup-Lab.ps1            # Lab cleanup script
```

## 📚 Lab Modules

### Core Modules (Required)

1. **Module 0**: Infrastructure Setup (15 min)
2. **Module 1**: Network Connectivity Validation (10 min)
3. **Module 2**: Azure Arc Server Onboarding (15 min)
4. **Module 3**: SQL Server Extension & Auto-Discovery (15 min)
5. **Module 4**: License Type Management (20 min)
6. **Module 5**: Basic Monitoring Setup (15 min)
7. **Module 6**: Best Practices Assessment (20 min)
8. **Module 7**: Azure Policy for BPA at Scale (25 min)

**Core Lab Duration:** ~2 hours 15 minutes

### Optional Advanced Modules (Preview Features)

> ⚠️ **Preview Features Notice**: These modules use preview features subject to [Azure Preview Terms](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).  
> Skip if time is limited or production preview restrictions apply.

9. **Module 8 (Optional)**: Configure Automatic Updates (10 min)
10. **Module 9 (Optional)**: Advanced SQL Monitoring (20 min)
11. **Module 10 (Optional)**: Automated Backups & Point-in-Time Restore (40 min)

**Optional Modules Duration:** +70 minutes

### Cleanup

12. **Module 11**: Lab Cleanup (10 min)

**Complete Lab Duration (with optional modules):** ~3 hours 30 minutes

## 🏁 Getting Started

### Step 1: Clone Repository

```powershell
git clone https://github.com/microsoft/azure-arc-enabled-sql-server.git
cd azure-arc-enabled-sql-server/arc-sql-hands-on-lab
```

### Step 2: Deploy Infrastructure

```powershell
cd bicep
Connect-AzAccount
Set-AzContext -SubscriptionId "<your-subscription-id>"
.\deploy.ps1 -BaseName "arcsql-lab" -Environment "dev"
```

### Step 3: Follow Lab Guide

Open [README.md](README.md) and follow the module-by-module instructions.

## 🔧 What You'll Deploy

This lab creates the following Azure resources in **Sweden Central**:

- **2 Resource Groups:**
  - `arcsql-lab-arc-rg` - For Azure Arc resources
  - `arcsql-lab-monitoring-rg` - For Log Analytics

- **Log Analytics Workspace** - For monitoring and Best Practices Assessment

- **Azure Arc Resources** (after onboarding):
  - Arc-enabled Server
  - Arc-enabled SQL Server instances
  - Azure extensions

## 🧹 Cleanup

To remove all lab resources:

```powershell
cd scripts
.\Cleanup-Lab.ps1 -SubscriptionId "<your-subscription-id>" -BaseName "arcsql-lab"
```

## 📖 Learning Outcomes

After completing this lab, you will understand:

**Core Skills:**
✅ How to deploy Azure infrastructure using Bicep  
✅ Network requirements for Azure Arc  
✅ Arc onboarding process and automation  
✅ Automatic SQL Server discovery  
✅ License type options (PAYG, Paid, LicenseOnly)  
✅ Transitioning between license types  
✅ Monitoring capabilities for Arc-enabled SQL Server  
✅ Best Practices Assessment configuration and results  
✅ Using Azure Policy for governance at scale  

**Optional Advanced Skills:**
✅ Configuring automatic Windows and SQL Server updates  
✅ Advanced performance monitoring with DMV-based metrics  
✅ Setting up automated backups with retention policies  
✅ Performing point-in-time database restores  

**General:**
✅ Complete lifecycle management of Arc-enabled SQL Server

## 🔗 Additional Resources

- [SQL Server enabled by Azure Arc - Overview](https://learn.microsoft.com/sql/sql-server/azure-arc/overview)
- [Azure Arc Documentation](https://learn.microsoft.com/azure/azure-arc/)
- [Azure Policy for Arc SQL](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#sql-server)
- [Best Practices Assessment](https://learn.microsoft.com/sql/sql-server/azure-arc/assess)

## 🤝 Support

- **Issues**: [GitHub Issues](https://github.com/microsoft/azure-arc-enabled-sql-server/issues)
- **Documentation**: [Microsoft Learn](https://learn.microsoft.com/sql/sql-server/azure-arc/)
- **Community**: [Microsoft Q&A](https://learn.microsoft.com/answers/tags/146/azure-arc)

## 📄 License

© Microsoft Corporation. Licensed under the Apache License, Version 2.0.
