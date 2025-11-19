# Prerequisites

This lab requires three distinct environments to be properly configured before you begin.

---

## 1️⃣ Management Workstation Requirements

**Your Windows or macOS machine from which you'll run lab commands and scripts**

<details>
<summary><b>Click to expand workstation requirements</b></summary>

### Operating System
- **Windows 11** (latest 2 versions) OR
- **macOS** (latest 2 versions)

### Required Software

#### PowerShell 7.4 or Higher
- **Download**: [PowerShell 7.4+](https://github.com/PowerShell/PowerShell/releases)
- **Installation**:
  - **Windows**: Download and run the MSI installer
  - **macOS**: `brew install --cask powershell` or download PKG installer
- **Verify**: `pwsh --version` (should show 7.4.0 or higher)

#### Azure CLI (version 2.50.0 or higher)
- **Download**: [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- **Installation**:
  - **Windows**: Download and run the MSI installer
  - **macOS**: `brew install azure-cli`
- **Verify**: `az --version` (should show 2.50.0 or higher)

#### Bicep CLI
- **Installation**: `az bicep install`
- **Update**: `az bicep upgrade`
- **Verify**: `az bicep version`

#### Azure PowerShell Module
- **Installation**:
  ```powershell
  Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
  ```
- **Verify**: `Get-Module -Name Az -ListAvailable`
- **Minimum Version**: Az 10.0.0 or higher recommended

### Recommended Software

#### Visual Studio Code
- **Download**: [VS Code](https://code.visualstudio.com/)
- **Recommended Extensions**:
  - PowerShell (`ms-vscode.powershell`)
  - Bicep (`ms-azuretools.vscode-bicep`)
  - Azure Account (`ms-vscode.azure-account`)
  - Azure Resources (`ms-azuretools.vscode-azureresourcegroups`)

#### Git (Optional)
- **Purpose**: Clone the lab repository
- **Download**: [Git](https://git-scm.com/downloads)
- **Alternative**: Download repository as ZIP from GitHub

### Network Requirements
- ✅ Internet connectivity (direct or via proxy)
- ✅ No corporate firewall blocking Azure endpoints
- ✅ Ability to connect to target on-premises server (RDP for Windows)
- ✅ If using proxy: Configure `HTTP_PROXY` and `HTTPS_PROXY` environment variables

</details>

---

## 2️⃣ Azure Subscription Requirements

**What you need in your Azure environment before starting the lab**

<details>
<summary><b>Click to expand Azure requirements</b></summary>

### Subscription Access
- **Active Azure subscription** (trial, pay-as-you-go, or enterprise)
- **Required Role**: **Owner** (preferred)
  - Needed for: Creating service principals, assigning roles, deploying resources
- **Minimum Roles** (alternative):
  - **Contributor** (for resource creation)
  - **User Access Administrator** (for role assignments)

### Resource Provider Registration
The following resource providers must be registered in your subscription (Module 0 will guide you through registration if needed):

| Resource Provider | Purpose |
|-------------------|---------|
| `Microsoft.HybridCompute` | Azure Arc-enabled servers |
| `Microsoft.AzureArcData` | SQL Server extension for Arc |
| `Microsoft.OperationalInsights` | Log Analytics workspace |
| `Microsoft.GuestConfiguration` | Policy compliance and guest configuration |

**Check registration status**:
```powershell
Get-AzResourceProvider -ProviderNamespace Microsoft.HybridCompute
Get-AzResourceProvider -ProviderNamespace Microsoft.AzureArcData
Get-AzResourceProvider -ProviderNamespace Microsoft.OperationalInsights
Get-AzResourceProvider -ProviderNamespace Microsoft.GuestConfiguration
```

### Resource Availability
- ✅ No pre-existing resource groups with these names:
  - `arcsql-lab-arc-rg`
  - `arcsql-lab-monitoring-rg`
- ✅ Sufficient subscription quota for:
  - Azure Arc-enabled servers (minimum 1)
  - Log Analytics workspace (1)

### Azure Region
- **Default Region**: `swedencentral`
- **Requirements**:
  - Azure Arc-enabled servers available in chosen region
  - SQL Server enabled by Azure Arc available in chosen region
- **Check Availability**: [Azure Products by Region](https://azure.microsoft.com/global-infrastructure/services/?products=azure-arc)

### Cost Considerations
- **Estimated Lab Cost**: $5-15 USD per day (varies by license type and features enabled)
- **Billable Components**:
  - Azure Arc-enabled SQL Server (if using PAYG license)
  - Log Analytics workspace (data ingestion and retention)
  - Azure Monitor (if using advanced monitoring - preview)
- **Cost Control**:
  - Complete Module 11 (Cleanup) when finished
  - Delete all resource groups to stop charges
  - Monitor costs via Azure Cost Management

</details>

---

## 3️⃣ Target Server (On-Premises) Requirements

**The Windows Server with SQL Server that will be onboarded to Azure Arc**

<details>
<summary><b>Click to expand target server requirements</b></summary>

### Operating System
- **Windows Server 2016 or higher**
  - Windows Server 2019 (recommended)
  - Windows Server 2022 (recommended)

### SQL Server
- **Version**: SQL Server 2012 or higher
  - SQL Server 2017 or higher (recommended for full feature support)
  - SQL Server 2019/2022 (best experience with all preview features)
- **Edition**: Standard or Enterprise
  - Express edition not supported for Best Practices Assessment
- **Status**: Already installed and running
- **Licensing**: 
  - Already licensed (bring your own license)
  - If using "Paid" license type: Must have Software Assurance or SQL Server subscription

### Server Access Requirements
- **Local Administrator** privileges on the Windows Server
- **RDP access** from your management workstation
- **Windows Firewall**: Allow inbound RDP (TCP 3389) from management workstation

### SQL Server Access Requirements
- **SQL Server sysadmin role** (required for):
  - Best Practices Assessment
  - Advanced monitoring features
  - Automated backups (preview feature)
- **Authentication**: Mixed mode or Windows authentication

### Network Connectivity
- **Outbound HTTPS** (TCP port 443) to Azure endpoints
- **DNS Resolution** for these domains:
  - `*.azure.com`
  - `*.microsoft.com`
  - `*.guestconfiguration.azure.com`
  - `*.his.arc.azure.com`
  - `*.swedencentral.arcdataservices.com` (or your chosen region)
- **Internet Connectivity**: Direct or via proxy (see Module 1 for proxy configuration)

### System Resources
- **Minimum**:
  - 2 vCPUs
  - 4 GB RAM
  - 20 GB available disk space
- **Recommended**:
  - 4+ vCPUs
  - 8+ GB RAM
  - 100+ GB available disk space (for SQL databases and backups)

### Exclusions (What NOT to Use)
- ❌ Server already connected to Azure Arc
- ❌ SQL Server failover cluster instance (FCI) - preview features not supported
- ❌ Always On Availability Group (AG) secondary replica - cannot be onboarded
- ❌ SQL Server running in a container
- ❌ Azure SQL VM (already managed by Azure)

### Optional: Backup Configuration
**Only needed if completing Module 10 (Automated Backups)**
- Default SQL Server backup location configured and accessible
- Sufficient disk space for automated backups (plan for retention period)
- If using network share: `NT AUTHORITY\SYSTEM` has write permissions

</details>

---

## 📚 Knowledge Prerequisites

**Skills and knowledge needed to successfully complete this lab**

<details>
<summary><b>Click to expand required skills</b></summary>

### Required Knowledge
- ✅ **SQL Server Administration**:
  - Install and configure SQL Server
  - Connect to SQL Server via SSMS or sqlcmd
  - Basic T-SQL queries
  - Understanding of SQL Server instances and databases
- ✅ **Windows Server Administration**:
  - Remote Desktop (RDP) connection
  - Windows services management
  - Basic Windows security and permissions
- ✅ **PowerShell Basics**:
  - Running PowerShell scripts
  - Understanding cmdlets and parameters
  - Basic variables and flow control
- ✅ **Azure Portal Navigation**:
  - Finding resources
  - Navigating blades and settings
  - Basic understanding of Azure concepts

### Recommended Knowledge
- 🟡 **Azure Resource Manager (ARM)**:
  - Resource groups and subscriptions
  - Resource hierarchy
  - Tags and organization
- 🟡 **Infrastructure as Code**:
  - Bicep or ARM templates basics
  - Declarative vs imperative deployment
- 🟡 **Azure CLI or Azure PowerShell**:
  - Experience using either tool
  - Understanding authentication and context
- 🟡 **SQL Server Licensing**:
  - Software Assurance (SA)
  - Azure Hybrid Benefit (AHB)
  - Pay-as-you-go (PAYG) vs Paid vs LicenseOnly
- 🟡 **Networking Basics**:
  - DNS and name resolution
  - Firewall and proxy concepts
  - TCP/IP and common ports

### Optional Knowledge (For Advanced Modules)
- 🔵 **Azure Policy and Governance**:
  - Policy definitions and assignments
  - Compliance and remediation
  - Managed identities
- 🔵 **Azure Monitor and Log Analytics**:
  - KQL (Kusto Query Language) basics
  - Workspaces and data collection
  - Creating alerts and dashboards
- 🔵 **SQL Server Dynamic Management Views (DMVs)**:
  - Performance monitoring DMVs
  - Wait statistics
  - Session and connection information
- 🔵 **Backup and Recovery Strategies**:
  - Full, differential, and transaction log backups
  - Recovery models (Full, Simple, Bulk-logged)
  - Point-in-time restore concepts

</details>

---

## ✅ Prerequisites Checklist

Before starting Module 0, verify you have:

**Management Workstation:**
- [ ] Windows 11 or macOS (latest 2 versions)
- [ ] PowerShell 7.4+
- [ ] Azure CLI 2.50.0+
- [ ] Bicep CLI installed
- [ ] Azure PowerShell Module (Az)
- [ ] Visual Studio Code (recommended)
- [ ] Network connectivity to Azure and target server

**Azure Subscription:**
- [ ] Active subscription with Owner or Contributor + User Access Administrator roles
- [ ] Resource providers registered (or ready to register in Module 0)
- [ ] No conflicting resource group names
- [ ] Chosen Azure region supports Arc-enabled SQL Server

**Target Server:**
- [ ] Windows Server 2016+ with SQL Server 2012+ installed
- [ ] Local administrator and SQL sysadmin access
- [ ] Outbound HTTPS (port 443) connectivity to Azure
- [ ] Not already in Arc, not FCI, not AG secondary
- [ ] Minimum 2 vCPUs, 4 GB RAM

**Knowledge:**
- [ ] SQL Server administration basics
- [ ] Windows Server and PowerShell fundamentals
- [ ] Azure portal navigation

**Ready to begin?** Proceed to [Module 0: Infrastructure Setup](README.md#module-0-infrastructure-setup-15-minutes)

---

## 🆘 Need Help?

- **Documentation**: [SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/overview)
- **Prerequisites Guide**: [Connect SQL Server to Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/prerequisites)
- **Azure Arc Jumpstart**: [Arc-enabled SQL Server scenarios](https://azurearcjumpstart.io/)
- **Support**: Open an issue in this repository or contact Microsoft Support
