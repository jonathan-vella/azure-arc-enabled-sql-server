# Azure Arc-Enabled SQL Server - Hands-On Lab

**Duration:** 2 hours (core modules), 3+ hours (with optional preview modules)  
**Level:** Intermediate  
**Target Audience:** IT Professionals, System Administrators, Cloud Architects

> [!IMPORTANT]
> **Preview Features:** This lab includes 4 optional modules (Modules 8-11) that cover preview features. These features are subject to [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/). If you are time-limited, you may skip these optional modules and proceed directly to Module 12 (Lab Cleanup).

## Overview

This comprehensive hands-on lab guides you through the complete lifecycle of managing SQL Server instances with Azure Arc. You will learn how to onboard on-premises SQL Server instances to Azure Arc, manage licensing, enable monitoring, implement best practices assessment, and leverage Azure Policy for governance at scale.

**Optional preview modules** cover automated patching, advanced monitoring, backup management, and point-in-time restore capabilities.

### Lab Architecture

![SQL Server - Azure Arc Architecture](../media/sql%20server%20-%20azure%20arc%20-%20architecture%20diagram.png)

### What You Will Learn

- Deploy Azure infrastructure for Arc-enabled SQL Server using Bicep
- Validate network connectivity requirements for Azure Arc
- Onboard on-premises SQL Server to Azure Arc
- Configure automatic SQL instance discovery
- Manage license types (PAYG, Paid/Software Assurance)
- Transition between license types
- Enable and configure SQL Server monitoring
- Implement Best Practices Assessment (BPA)
- Deploy Azure Policy for BPA at scale
- Clean up and deprovision resources

**Optional preview features:**
- Configure automated patching for SQL Server
- Enable advanced performance monitoring
- Set up automated backup management
- Perform point-in-time database restores

### Prerequisites

#### Azure Requirements
- Active Azure subscription with **Owner** permissions
- No pre-existing resource groups (you will create your own)
- Resource providers registered: `Microsoft.HybridCompute`, `Microsoft.AzureArcData`, `Microsoft.OperationalInsights`

#### On-Premises Environment
- **Windows Server**: 2022 or higher
- **SQL Server**: 2017 or higher (Standard or Enterprise edition)
- SQL Server **already installed and licensed**
- Local administrator access to the server
- Network connectivity to Azure (outbound HTTPS on TCP port 443)

#### Tools & Software
- **PowerShell**: 7.0 or higher
- **Azure PowerShell Module**: Latest version
  ```powershell
  Install-Module -Name Az -AllowClobber -Force
  ```
- **Azure CLI** (optional): Latest version
- **Bicep CLI**: Latest version
  ```powershell
  az bicep install
  ```

#### Knowledge Prerequisites
- Basic understanding of SQL Server administration
- Familiarity with PowerShell scripting
- Basic knowledge of Azure concepts (resource groups, subscriptions)
- Understanding of Azure Resource Manager (ARM) and Bicep

---

## Lab Modules

### Core Modules

### Module 0: Infrastructure Setup (15 minutes)

Deploy the required Azure infrastructure using Bicep templates.

**Objectives:**
- Deploy resource groups for Arc resources and monitoring
- Create Log Analytics workspace for monitoring and BPA
- Register required resource providers

**Steps:**

1. **Clone the repository** (if you haven't already):
   ```powershell
   git clone https://github.com/microsoft/azure-arc-enabled-sql-server.git
   cd azure-arc-enabled-sql-server/arc-sql-hands-on-lab
   ```

2. **Review the Bicep templates**:
   - `bicep/main.bicep` - Main deployment template
   - `bicep/modules/log-analytics.bicep` - Log Analytics workspace

3. **Deploy the infrastructure**:
   ```powershell
   cd bicep
   
   # Connect to Azure
   Connect-AzAccount
   
   # Set your subscription (replace with your subscription ID)
   Set-AzContext -SubscriptionId "<your-subscription-id>"
   
   # Deploy the template
   .\deploy.ps1 -BaseName "arcsql-lab" -Environment "dev"
   ```

4. **Verify deployment**:
   - Check the Azure portal for the two resource groups:
     - `arcsql-lab-arc-rg` (for Arc resources)
     - `arcsql-lab-monitoring-rg` (for Log Analytics workspace)

**Validation:**
- ✅ Two resource groups created in Sweden Central
- ✅ Log Analytics workspace deployed with SQL Assessment solution
- ✅ Deployment outputs saved to `deployment-outputs.json`

---

### Module 1: Network Connectivity Validation (10 minutes)

Validate that your on-premises server can communicate with Azure Arc endpoints.

**Objectives:**
- Verify outbound connectivity to required Azure endpoints
- Test DNS resolution for Arc services
- Validate firewall and proxy configuration

**Steps:**

1. **Run the network connectivity test**:
   ```powershell
   cd ../scripts
   .\Test-ArcConnectivity.ps1 -Region "swedencentral" -Verbose
   ```

2. **Review the connectivity report**:
   - Check all required endpoints are accessible
   - Verify DNS resolution is working
   - Confirm no proxy issues

3. **Remediate any connectivity issues**:
   - If using a proxy, configure `https_proxy` environment variable
   - Ensure firewall allows outbound HTTPS (port 443) to Azure endpoints
   - Validate `*.swedencentral.arcdataservices.com` is accessible

**Required Endpoints:**
- `management.azure.com`
- `login.microsoftonline.com`
- `*.guestconfiguration.azure.com`
- `*.his.arc.azure.com`
- `*.swedencentral.arcdataservices.com`

**Validation:**
- ✅ All Azure Arc endpoints are accessible
- ✅ DNS resolution working for all required domains
- ✅ No connectivity errors reported

---

### Module 2: Azure Arc Server Onboarding (20 minutes)

Connect your on-premises Windows Server to Azure Arc using Service Principal authentication.

**Objectives:**
- Create Service Principal for Arc onboarding
- Grant required permissions to Service Principal
- Install Azure Connected Machine agent using Service Principal
- Register the server with Azure Arc
- Verify server appears in Azure portal

**Steps:**

#### Part A: Create Service Principal (5 minutes)

1. **Run the service principal creation script** on your **workstation** (not the on-premises server):
   ```powershell
   cd scripts
   .\Create-ArcServicePrincipal.ps1 `
       -ServicePrincipalName "Arc-SQL-Lab-Onboarding-SP" `
       -Scope "Subscription"
   ```

2. **Securely save the output credentials**:
   - **Application ID** (appId)
   - **Secret** (password) - This is sensitive!
   - **Tenant ID**
   - **Subscription ID**
   
   **Important**: The secret is displayed only once and saved to `service-principal-credentials.json`. Store these credentials securely (e.g., Azure Key Vault, password manager) and delete the JSON file afterward.

3. **Understand the role assignment**:
   - Role: **Azure Connected Machine Onboarding**
   - Scope: Subscription-level
   - Permissions: Minimum required to onboard servers to Arc
   - Service Principal is used ONLY during onboarding, not for ongoing management

#### Part B: Onboard Server to Arc (15 minutes)

1. **Download the Azure Connected Machine agent** on your on-premises server:
   - Visit: https://aka.ms/AzureConnectedMachineAgent
   - Or use PowerShell:
   ```powershell
   # On the on-premises server
   $ProgressPreference = 'SilentlyContinue'
   Invoke-WebRequest -Uri "https://aka.ms/AzureConnectedMachineAgent" `
       -OutFile "$env:TEMP\AzureConnectedMachineAgent.msi"
   ```

2. **Install the agent** on your on-premises server:
   ```powershell
   # Run in elevated PowerShell on the on-premises server
   msiexec /i "$env:TEMP\AzureConnectedMachineAgent.msi" /qn /l*v "$env:TEMP\InstallationLog.txt"
   ```

3. **Connect the server to Azure Arc using Service Principal**:
   
   Replace the placeholders with your actual values from the service principal creation:
   
   ```powershell
   # Set variables (replace with your actual values)
   $servicePrincipalAppId = "<Application-ID-from-previous-step>"
   $servicePrincipalSecret = "<Secret-from-previous-step>"
   $tenantId = "<Tenant-ID-from-previous-step>"
   $subscriptionId = "<Subscription-ID-from-previous-step>"
   $resourceGroup = "arcsql-lab-arc-rg"
   $location = "swedencentral"
   
   # Connect to Azure Arc
   & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect `
       --service-principal-id $servicePrincipalAppId `
       --service-principal-secret $servicePrincipalSecret `
       --tenant-id $tenantId `
       --subscription-id $subscriptionId `
       --resource-group $resourceGroup `
       --location $location
   ```

4. **Verify agent installation**:
   ```powershell
   # Check agent status
   & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" show
   ```
   
   Expected output should show:
   - Agent Status: **Connected**
   - Azure Resource Name
   - Resource Group
   - Subscription ID

5. **Verify in Azure portal**:
   - Navigate to **Azure Arc** > **Infrastructure** > **Servers**
   - Confirm your server appears with status **Connected**
   - Review server properties (OS, location, agent version)

**Why Service Principal Instead of Interactive Login?**
- ✅ **Automation-friendly**: No user interaction required
- ✅ **Enterprise-ready**: Suitable for at-scale deployments
- ✅ **Security**: Principle of least privilege with limited permissions
- ✅ **Auditable**: All actions traced to service principal
- ✅ **Repeatable**: Can be used for multiple servers

**Validation:**
- ✅ Service Principal created with Azure Connected Machine Onboarding role
- ✅ Credentials stored securely
- ✅ Azure Connected Machine agent installed successfully
- ✅ Server visible in Azure portal under Arc > Servers
- ✅ Server status shows as **Connected**
- ✅ Server resource in `arcsql-lab-arc-rg` resource group
- ✅ Agent reports status when running `azcmagent show`

---

### Module 3: SQL Server Extension Deployment & Auto-Discovery (15 minutes)

Deploy the Azure extension for SQL Server and enable automatic SQL instance discovery.

**Objectives:**
- Understand automatic SQL discovery process
- Deploy Azure extension for SQL Server
- Verify SQL instances are discovered and registered
- Review SQL Server resources in Azure

**Steps:**

1. **Understand auto-discovery**:
   - When a server is connected to Arc, SQL instances are automatically discovered
   - The `WindowsAgent.SqlServer` extension is deployed automatically
   - SQL Server - Azure Arc resources are created for each instance

2. **Verify automatic extension deployment**:
   - Navigate to your Arc-enabled server in the portal
   - Go to **Extensions** tab
   - Look for **WindowsAgent.SqlServer** extension
   - Status should be **Succeeded**

3. **If extension was NOT auto-deployed**, manually deploy it:
   ```powershell
   # Get your Arc server resource
   $serverName = "<your-server-name>"
   $resourceGroup = "arcsql-lab-arc-rg"
   
   # Deploy SQL Server extension
   New-AzConnectedMachineExtension `
       -ResourceGroupName $resourceGroup `
       -MachineName $serverName `
       -Name "WindowsAgent.SqlServer" `
       -Publisher "Microsoft.AzureData" `
       -ExtensionType "WindowsAgent.SqlServer" `
       -Location "swedencentral" `
       -EnableAutomaticUpgrade
   ```

4. **Verify SQL Server instances discovered**:
   - Navigate to **Azure Arc** > **Data services** > **SQL Server instances**
   - Confirm your SQL Server instance(s) appear
   - Note the resource group and region (same as Arc server)

5. **Review SQL Server resource properties**:
   - Click on a SQL Server instance
   - Review **Overview** page
   - Note: Edition, Version, vCores, License Type (initially "Configuration needed")

**Validation:**
- ✅ WindowsAgent.SqlServer extension deployed and running
- ✅ SQL Server instance(s) visible in Azure Arc > SQL Server instances
- ✅ Instance details showing edition, version, and configuration
- ✅ No deployment errors in extension status

---

### Module 4: License Type Management (20 minutes)

Configure and transition between different SQL Server license types.

**Objectives:**
- Understand SQL Server licensing options in Azure Arc
- Configure initial license type (PAYG)
- Transition to Paid (Software Assurance/Azure Hybrid Benefit)
- Understand billing implications

**Steps:**

#### Part A: Configure PAYG (Pay-As-You-Go) License

1. **Navigate to your SQL Server instance** in Azure portal:
   - **Azure Arc** > **Data services** > **SQL Server instances**
   - Select your instance

2. **Configure PAYG licensing**:
   - Go to **Configuration** blade
   - Under **License type**, select **Pay-as-you-go**
   - Review the pricing information
   - Click **Save**

3. **Verify configuration**:
   - Confirm license type updated to **Pay-as-you-go**
   - Check the **Billing information** section

#### Part B: Transition to Paid (Software Assurance)

Since your SQL Server is already licensed with Software Assurance, transition to the Paid license type to unlock advanced features.

1. **Update license type to Paid**:
   - Navigate to **Configuration** blade
   - Change **License type** to **Paid** (License with Software Assurance or SQL subscription)
   - Click **Save**

2. **Verify advanced features are now available**:
   - Check that **Best Practices Assessment** is now configurable
   - Verify **Monitoring** features are enabled

#### Part C: Using PowerShell for License Management

For managing licenses at scale:

```powershell
# Set license type to PAYG
$resourceGroup = "arcsql-lab-arc-rg"
$sqlServerArcName = "<your-sql-server-arc-resource-name>"

Update-AzSqlInstanceArc `
    -ResourceGroupName $resourceGroup `
    -Name $sqlServerArcName `
    -LicenseType "PAYG"

# Set license type to Paid (Software Assurance)
Update-AzSqlInstanceArc `
    -ResourceGroupName $resourceGroup `
    -Name $sqlServerArcName `
    -LicenseType "Paid"
```

**Understanding License Types:**

| License Type | Description | Features | Billing |
|-------------|-------------|----------|---------|
| **PAYG** | Pay-as-you-go subscription | Full features, no upfront license cost | Hourly billing based on vCores |
| **Paid** | License with Software Assurance | Full features, use existing licenses | No SQL license charges, only management services |
| **LicenseOnly** | Bring your own license (no SA) | Limited features, basic management only | No charges |

**Validation:**
- ✅ Successfully configured PAYG license type
- ✅ Successfully transitioned to Paid license type
- ✅ License type reflected correctly in Azure portal
- ✅ Advanced features (BPA, Monitoring) now available

---

### Module 5: Basic Monitoring Setup (15 minutes)

Enable basic monitoring for your Arc-enabled SQL Server instance.

**Objectives:**
- Understand monitoring capabilities for Arc-enabled SQL Server
- Enable basic monitoring features
- Review monitoring dashboards
- Understand data collection

**Steps:**

1. **Verify monitoring prerequisites**:
   - SQL Server version 2016 SP1 or later
   - License type: **Paid** or **PAYG** (not LicenseOnly)
   - Extension version 1.1.2504.99 or later

2. **Enable monitoring** (if not already enabled):
   - Navigate to your SQL Server Arc resource
   - Go to **Monitoring** blade
   - If monitoring is not enabled, follow the prompts to enable it

3. **Review available monitoring dashboards**:
   - **Performance Dashboard**: View CPU, memory, I/O metrics
   - **Database Inventory**: See all databases on the instance
   - **SQL Server Overview**: Instance-level metrics and health

4. **Understand data collection**:
   - Monitoring data is collected automatically
   - Performance metrics sent to Azure every 5 minutes
   - No Log Analytics workspace integration required for basic monitoring

5. **Explore monitoring data**:
   - Go to **Monitoring** > **Performance**
   - Select different time ranges
   - Review CPU, memory, and I/O trends

**Note:** Advanced monitoring configuration (custom queries, alerts, dashboards) is out of scope for this lab.

**Validation:**
- ✅ Monitoring enabled on SQL Server Arc resource
- ✅ Performance dashboards displaying data
- ✅ Database inventory visible
- ✅ No monitoring errors reported

---

### Module 6: Best Practices Assessment (20 minutes)

Enable and run SQL Server Best Practices Assessment to identify configuration improvements.

**Objectives:**
- Enable Best Practices Assessment (BPA)
- Configure BPA to use Log Analytics workspace
- Run an assessment
- Review assessment results and recommendations

**Steps:**

1. **Verify BPA prerequisites**:
   - License type: **Paid** or **PAYG**
   - Windows operating system (BPA not supported on Linux)
   - Log Analytics workspace deployed (from Module 0)

2. **Enable BPA from Azure portal**:
   - Navigate to your SQL Server Arc resource
   - Go to **Best practices assessment** blade
   - Click **Configure**
   - Select:
     - **Log Analytics workspace**: `arcsql-lab-law-<unique>`
     - **Assessment schedule**: Weekly (Sunday, 12:00 AM)
   - Click **Enable**

3. **Run an immediate assessment**:
   - On the **Best practices assessment** blade
   - Click **Run assessment now**
   - Wait for assessment to complete (5-15 minutes depending on DB count)

4. **Review assessment results**:
   - Once complete, review the **Assessment results** page
   - Results are categorized by:
     - **Severity**: High, Medium, Low, Informational
     - **Category**: Configuration, Performance, Security, etc.
   - Click on individual recommendations to see:
     - Detailed description
     - Impact analysis
     - Remediation steps
     - Links to documentation

5. **Export assessment results** (optional):
   - Click **Export** to download results as CSV or JSON
   - Use for reporting or tracking remediation progress

**Understanding BPA Results:**

BPA evaluates your SQL Server configuration against Microsoft best practices:
- **Configuration**: SQL Server and database settings
- **Index Management**: Missing or unused indexes
- **Statistics**: Statistics that need updating
- **Deprecated Features**: Use of deprecated features
- **Trace Flags**: Trace flags that should be enabled/disabled

**Validation:**
- ✅ BPA enabled and configured with Log Analytics workspace
- ✅ Assessment ran successfully
- ✅ Assessment results visible in Azure portal
- ✅ Can view detailed recommendations and remediation steps

---

### Module 7: Azure Policy for BPA at Scale (25 minutes)

Deploy Azure Policy to automatically enable Best Practices Assessment across multiple SQL Server instances.

**Objectives:**
- Understand Azure Policy for Arc-enabled SQL Server
- Deploy built-in policy for BPA enablement
- Configure policy parameters
- Create remediation tasks
- Verify policy compliance

**Steps:**

#### Part A: Understand the Policy

1. **Review the built-in policy**:
   - Policy name: **Configure Arc-enabled Servers with SQL Server extension installed to enable or disable SQL best practices assessment**
   - Policy ID: `f36de009-cacb-47b3-b936-9c4c9120d064`
   - Effect: `DeployIfNotExists`

2. **Understand policy behavior**:
   - Automatically enables BPA on SQL Server Arc resources
   - Only applies to instances with **Paid** or **PAYG** license types
   - Requires Log Analytics workspace
   - Creates remediation tasks for non-compliant resources

#### Part B: Assign the Policy

1. **Navigate to Azure Policy** in Azure portal:
   - Search for "Policy" in the top search bar
   - Select **Azure Policy**

2. **Find the BPA policy definition**:
   - Go to **Definitions** blade
   - Search for: "Configure Arc-enabled Servers with SQL Server extension"
   - Click on the policy to open details

3. **Assign the policy**:
   - Click **Assign**
   - **Basics** tab:
     - **Scope**: Select your subscription
     - **Exclusions**: None (unless needed)
     - Click **Next**
   
   - **Parameters** tab:
     - **Show only parameters that need input**: Checked
     - **Enablement**: `true` (enable BPA)
     - **Log Analytics workspace**: Select `arcsql-lab-law-<unique>`
     - **Log Analytics workspace location**: `swedencentral`
     - Click **Next**
   
   - **Remediation** tab:
     - **Create a remediation task**: Checked
     - **Managed Identity Type**: System assigned (recommended)
     - **Managed Identity Location**: `swedencentral`
     - Click **Next**
   
   - **Non-compliance messages** tab:
     - Add custom message (optional): "SQL Server Best Practices Assessment must be enabled"
     - Click **Next**
   
   - **Review + Create**:
     - Review all settings
     - Click **Create**

#### Part C: Monitor Policy Compliance

1. **View policy assignment**:
   - Go to **Azure Policy** > **Assignments**
   - Find your BPA policy assignment
   - Click to view details

2. **Check compliance state**:
   - Go to **Compliance** tab
   - Policy evaluation may take 10-30 minutes for initial scan
   - Refresh the page periodically

3. **View non-compliant resources** (if any):
   - Click on the policy assignment
   - Go to **Resource compliance** tab
   - Review any non-compliant SQL Server instances

4. **Monitor remediation task**:
   - Go to **Remediation** blade under Azure Policy
   - Find your BPA policy remediation task
   - Click to view:
     - Remediation status
     - Resources remediated
     - Errors (if any)

5. **Verify BPA enabled on SQL instances**:
   - Navigate to **Azure Arc** > **SQL Server instances**
   - Select an instance
   - Go to **Best practices assessment** blade
   - Confirm BPA is enabled with correct Log Analytics workspace

#### Part D: Testing Policy Enforcement

1. **Simulate policy enforcement** (optional):
   - If you have another SQL Server to onboard, connect it to Arc
   - Policy should automatically enable BPA within 15-30 minutes
   - Verify in the portal that BPA was configured automatically

**Understanding Policy Scope:**

You can assign policies at different scopes:
- **Subscription**: Applies to all Arc SQL resources in the subscription
- **Resource Group**: Applies only to Arc SQL resources in specific resource groups
- **Management Group**: Applies across multiple subscriptions

**Validation:**
- ✅ Azure Policy successfully assigned at subscription scope
- ✅ Policy shows as **Compliant** for existing SQL Server instances
- ✅ Remediation task completed successfully
- ✅ BPA enabled on all applicable SQL Server instances via policy

---

### Optional Modules (Preview Features)

> [!IMPORTANT]
> **Preview Features Notice:** Modules 8-11 cover preview features that are subject to [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/). These modules are **optional** and can be skipped if you are time-limited. Preview features may have limited support and may change before general availability.

---

### Module 8: Automated Patching (15 minutes) ⚠️ OPTIONAL - PREVIEW

Configure automated patching to maintain SQL Server instances with the latest updates during scheduled maintenance windows.

**Objectives:**
- Understand automatic updates for Arc-enabled SQL Server
- Configure maintenance windows for patching
- Enable automated patching for SQL Server updates
- Understand Windows and SQL Server update management

**Prerequisites:**
- ✅ Module 2 completed (server onboarded to Arc)
- ✅ Module 3 completed (SQL Server extension deployed)
- ✅ License type set to **Paid** or **PAYG** (not LicenseOnly)

**Steps:**

#### Part A: Understanding Automated Patching

1. **Review patching capabilities**:
   - Automatic updates work at the OS level and apply to all SQL Server instances on the host
   - Updates occur only during configured maintenance windows
   - Only Windows and SQL Server updates marked as **Important** or **Critical** are applied
   - Service packs and cumulative updates not marked as Critical must be installed manually
   - Currently supported only on Windows hosts

2. **Key benefits**:
   - ✅ Minimizes maintenance overhead
   - ✅ Ensures servers stay current with security patches
   - ✅ Controlled update windows prevent unexpected downtime
   - ✅ Integrated with Windows Update and Microsoft Update services

#### Part B: Configure Automated Patching (Azure Portal)

1. **Navigate to your Arc-enabled server**:
   - Go to **Azure Arc** > **Infrastructure** > **Servers**
   - Select your Arc-enabled server

2. **Configure SQL Server patching**:
   - Under **Operations**, select **SQL Server Configuration**
   - Under **Update** section, configure:
     - **Automatic updates**: Select **Enable**
     - **Maintenance schedule**: Choose a day of the week (e.g., **Sunday**)
     - **Maintenance start hour**: Select maintenance window start time (e.g., **0:00** for midnight)
   - Click **Save**

3. **Verify configuration**:
   - Confirm automatic updates are enabled
   - Note the configured maintenance schedule
   - Review the estimated time for updates to apply

#### Part C: Configure Automated Patching (Azure CLI)

For automation at scale, use Azure CLI:

```azurecli
# Get your Arc server details
$resourceGroup = "arcsql-lab-arc-rg"
$serverName = "<your-arc-server-name>"

# Enable automated patching with maintenance schedule
az connectedmachine extension update \
    --resource-group $resourceGroup \
    --machine-name $serverName \
    --name "WindowsAgent.SqlServer" \
    --settings '{
        "AutoPatchingSettings": {
            "Enable": true,
            "DayOfWeek": "Sunday",
            "MaintenanceWindowStartingHour": 0,
            "MaintenanceWindowDuration": 60
        }
    }'
```

**Understanding Maintenance Windows:**

| Setting | Description | Values |
|---------|-------------|--------|
| **DayOfWeek** | Day for maintenance window | Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, or Daily |
| **MaintenanceWindowStartingHour** | Local time to start maintenance (24-hour format) | 0-23 |
| **MaintenanceWindowDuration** | Duration of maintenance window in minutes | 30-180 |

#### Part D: Monitor Update Status

1. **Check update history**:
   - On the on-premises server, go to **Settings** > **Update & Security** > **Windows Update**
   - Review **Update history** to see applied updates
   - Look for SQL Server updates in the history

2. **Verify SQL Server updates**:
   ```powershell
   # Check SQL Server version and patch level
   SELECT @@VERSION AS 'SQL Server Version';
   ```

3. **Review extension logs** (if needed):
   - Extension logs location: `C:\ProgramData\GuestConfig\extension_logs\Microsoft.AzureData.WindowsAgent.SqlServer\`
   - Check for any update-related messages or errors

**Important Notes:**
- ⚠️ Ensure your maintenance window is long enough for updates to complete
- ⚠️ Plan maintenance windows during low-usage periods
- ⚠️ Always test updates in non-production environments first
- ⚠️ Manual reboots may be required after certain updates

**Validation:**
- ✅ Automatic updates enabled in Azure portal
- ✅ Maintenance schedule configured for appropriate time window
- ✅ Settings saved successfully without errors
- ✅ Extension shows no configuration errors

**Troubleshooting:**

If automatic updates aren't working:
- Verify license type is **Paid** or **PAYG**
- Check that Windows Update service is running on the server
- Ensure network connectivity to Windows Update endpoints
- Review extension logs for error messages

**Additional Resources:**
- [Configure automatic updates for SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/update?view=sql-server-ver17)
- [Azure Update Manager documentation](https://learn.microsoft.com/azure/update-manager/overview)
- [Manage updates programmatically](https://learn.microsoft.com/azure/update-manager/manage-arc-enabled-servers-programmatically)

---

### Module 9: Advanced Monitoring (15 minutes) ⚠️ OPTIONAL - PREVIEW

Enable advanced performance monitoring with detailed metrics collection from SQL Server dynamic management views (DMVs).

> **Note:** This module extends Module 5 (Basic Monitoring) with additional capabilities. Module 5 should be completed before starting this module.

**Objectives:**
- Enable advanced performance monitoring for Arc-enabled SQL Server
- Understand collected monitoring datasets
- Review performance dashboards with detailed metrics
- Configure monitoring collection settings

**Prerequisites:**
- ✅ Module 5 completed (basic monitoring setup)
- ✅ SQL Server 2016 SP1 or later
- ✅ Windows operating system (not supported on Linux)
- ✅ Standard or Enterprise edition
- ✅ License type: **Paid** or **PAYG**
- ✅ Extension version 1.1.2504.99 or later

**Steps:**

#### Part A: Understanding Advanced Monitoring

1. **Review monitoring capabilities**:
   - Performance data collected from DMVs every 10-30 seconds
   - Near real-time processing in Azure telemetry pipeline
   - No Log Analytics workspace required for basic metrics
   - Data sent to `*.<region>.arcdataservices.com`

2. **Collected datasets include**:
   - **CPU Utilization**: Process-level and instance-level CPU metrics
   - **Memory Utilization**: Memory clerks and consumption patterns
   - **Storage I/O**: IOPS, throughput, and latency statistics
   - **Active Sessions**: Running requests, blockers, and open transactions
   - **Database Properties**: Configuration, options, and metadata
   - **Database Storage**: Space utilization and persistent version store
   - **Performance Counters**: 50+ common and detailed SQL Server counters
   - **Wait Statistics**: Wait types and resource waits

3. **Current limitations**:
   - ⚠️ Preview feature - subject to change
   - ⚠️ Failover cluster instances (FCI) not supported
   - ⚠️ Free during preview; pricing after GA to be determined

#### Part B: Enable Advanced Monitoring (Azure Portal)

1. **Navigate to SQL Server Arc resource**:
   - Go to **Azure Arc** > **Data services** > **SQL Server instances**
   - Select your SQL Server instance

2. **Verify monitoring is enabled**:
   - Select **Monitoring** > **Performance Dashboard (preview)**
   - If not enabled, click **Configure** and enable monitoring
   - Click **Apply settings**

3. **Explore performance dashboards**:
   - **Overview**: Instance-level health and key metrics
   - **CPU**: Process and SQL Server CPU utilization over time
   - **Memory**: Memory clerk consumption and trends
   - **Storage I/O**: Read/write IOPS, throughput, and latency per database file
   - **Active Sessions**: Current running queries, blockers, and connections
   - **Database Inventory**: All databases with properties and space usage

4. **Review detailed metrics**:
   - Select different time ranges (Last hour, Last 24 hours, Last 7 days)
   - Click on specific metrics to drill down into details
   - Note any performance anomalies or trends

#### Part C: Enable Advanced Monitoring (Azure CLI)

```azurecli
# Enable monitoring collection
az resource update \
    --ids "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.AzureArcData/SqlServerInstances/<sql-server-name>" \
    --set 'properties.monitoring.enabled=true' \
    --api-version 2023-09-01-preview
```

Example:

```azurecli
az resource update \
    --ids "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/arcsql-lab-arc-rg/providers/Microsoft.AzureArcData/SqlServerInstances/MyServer_MSSQLSERVER" \
    --set 'properties.monitoring.enabled=true' \
    --api-version 2023-09-01-preview
```

#### Part D: Verify Data Collection

1. **Check data collection status**:
   - In the Performance Dashboard, look for recent data points
   - Verify metrics are updating (refresh the page after a few minutes)
   - Confirm all datasets are being collected

2. **Review network connectivity**:
   ```powershell
   # Test connectivity to telemetry endpoint
   Test-NetConnection -ComputerName "telemetry.swedencentral.arcdataservices.com" -Port 443
   ```

3. **Validate collection on the server**:
   - Extension automatically queries DMVs at scheduled intervals
   - No impact on SQL Server performance (lightweight queries)
   - Check extension health in Azure portal under server extensions

#### Part E: Disable Monitoring (Optional)

If you need to disable monitoring:

**Azure Portal:**
- Go to **Performance Dashboard (preview)** > **Configure**
- Toggle monitoring to **Off**
- Click **Apply settings**

**Azure CLI:**
```azurecli
az resource update \
    --ids "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.AzureArcData/SqlServerInstances/<sql-server-name>" \
    --set 'properties.monitoring.enabled=false' \
    --api-version 2023-09-01-preview
```

**Understanding Collected Data:**

No personal data or customer content is collected. Only metadata and performance metrics are sent to Azure:

- Session IDs (no query text)
- Database names and IDs
- Performance counter values
- Wait statistics (aggregate only)
- File I/O metrics

**Validation:**
- ✅ Advanced monitoring enabled successfully
- ✅ Performance Dashboard displaying metrics
- ✅ Data updating in near real-time
- ✅ No connectivity errors to telemetry endpoints
- ✅ All required datasets collecting properly

**Troubleshooting:**

If monitoring data is not appearing:
- Verify SQL Server version is 2016 SP1 or later
- Check extension version (must be 1.1.2504.99 or later)
- Confirm license type is **Paid** or **PAYG**
- Test connectivity to `*.swedencentral.arcdataservices.com`
- Review extension logs for errors
- Wait 5-10 minutes for initial data collection

**Additional Resources:**
- [Monitor SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17)
- [Collected monitoring data reference](https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17#collected-data)
- [Network requirements for Azure Arc](https://learn.microsoft.com/azure/azure-arc/servers/network-requirements)

---

### Module 10: Backup Management (20 minutes) ⚠️ OPTIONAL - PREVIEW

> **Note:** This module is presented as a pair with Module 11 (Point-in-Time Restore). Complete both modules together for the full backup and restore experience.

Configure automated backups for SQL Server databases to local or network storage.

**Objectives:**
- Enable automated backups for Arc-enabled SQL Server
- Configure backup schedules (full, differential, transaction log)
- Set retention policies
- Understand backup management at instance and database levels

**Prerequisites:**
- ✅ Module 4 completed (license type configured)
- ✅ License type: **Paid** or **PAYG** (not LicenseOnly)
- ✅ Extension version 1.1.2504.99 or later
- ✅ Databases in **Full Recovery Model** for transaction log backups

**Steps:**

#### Part A: Understanding Automated Backups

1. **Review backup capabilities**:
   - Native SQL Server backups performed by the Azure extension
   - Backups written to default backup location (local or network share)
   - Support for full, differential, and transaction log backups
   - Configurable retention periods (1-35 days)
   - Instance-level or database-level policies

2. **Backup scheduling options**:
   - **Full backups**: Daily or weekly
   - **Differential backups**: Every 12 or 24 hours
   - **Transaction log backups**: Every 5, 10, 15, or 30 minutes
   - **Default schedule**: Full every 7 days, differential every 24 hours, T-log every 5 minutes

3. **Important considerations**:
   - ⚠️ Backups use NT AUTHORITY\SYSTEM account (or NT Service\SQLServerExtension with least privilege)
   - ⚠️ Default backup location must be accessible
   - ⚠️ Retention policy determines automatic cleanup
   - ⚠️ System databases backed up automatically (full backups only)

4. **Current limitations**:
   - Backup to URL (Azure Blob Storage) not currently available
   - Databases must be in Full Recovery Model for transaction log backups
   - Not supported for Always On Failover Cluster Instances (FCI)
   - Not supported for Always On Availability Group replicas

#### Part B: Configure Permissions (Extension v1.1.2504.99 and earlier)

> **Note:** If using extension version 1.1.2504.99 or later, permissions are granted automatically. Skip this step if using a newer version.

For earlier versions, grant permissions manually:

```sql
-- Add NT AUTHORITY\SYSTEM to logins
USE master;
GO
CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS WITH DEFAULT_DATABASE = [master];
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [NT AUTHORITY\SYSTEM];
GO

-- Add to each database as db_backupoperator
CREATE USER [NT AUTHORITY\SYSTEM] FOR LOGIN [NT AUTHORITY\SYSTEM];
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [NT AUTHORITY\SYSTEM];
GO
```

Run the user creation script for each user and system database (except `tempdb`).

#### Part C: Configure Instance-Level Backup (Azure Portal)

1. **Navigate to SQL Server Arc resource**:
   - Go to **Azure Arc** > **Data services** > **SQL Server instances**
   - Select your SQL Server instance

2. **Configure backup policy**:
   - Select **Backups**
   - Click **Configure policies**
   - Under **Configure policies**:
     - **Retention period**: `7` days (or 1-35 days)
     - **Full backup schedule**: `Weekly` (every 7 days)
     - **Differential backup schedule**: `24 hours`
     - **Transaction log backup schedule**: `5 minutes`
   - Click **Apply**

3. **Verify backup configuration**:
   - Confirm policy is saved
   - Note the next scheduled backup time
   - Check that all databases are included

#### Part D: Configure Instance-Level Backup (Azure CLI)

**Using default schedule:**

```azurecli
az sql server-arc backups-policy set \
    --name <arc-server-name> \
    --resource-group arcsql-lab-arc-rg \
    --default-policy
```

**Using custom schedule:**

```azurecli
az sql server-arc backups-policy set \
    --name <arc-server-name> \
    --resource-group arcsql-lab-arc-rg \
    --retention-days 14 \
    --full-backup-days 7 \
    --diff-backup-hours 24 \
    --tlog-backup-mins 10
```

Example for named instance:

```azurecli
az sql server-arc backups-policy set \
    --name MyServer_MSSQLSERVER \
    --resource-group arcsql-lab-arc-rg \
    --retention-days 14 \
    --full-backup-days 7 \
    --diff-backup-hours 24 \
    --tlog-backup-mins 10
```

#### Part E: Configure Database-Level Backup (Azure Portal)

For individual database backup policies:

1. **Navigate to the database**:
   - Select your SQL Server instance
   - Under **Data services**, find and select the database

2. **Configure database backup**:
   - Under **Data management**, select **Backup (preview)**
   - Click **Configure database backup policies (Preview)**
   - Click **Configure policies**
   - Set:
     - **Retention period**: `14` days
     - **Full backup schedule**: `7 days`
     - **Differential backup schedule**: `12 hours`
     - **Transaction log backup schedule**: `10 minutes`
   - Click **Apply**

> **Note:** Database-level policies take precedence over instance-level policies.

#### Part F: Configure Database-Level Backup (Azure CLI)

```azurecli
az sql db-arc backups-policy set \
    --name <database-name> \
    --server <arc-server-name> \
    --resource-group arcsql-lab-arc-rg \
    --retention-days 14 \
    --full-backup-days 7 \
    --diff-backup-hours 12 \
    --tlog-backup-mins 10
```

#### Part G: Verify Backup Execution

1. **Check backup history in SQL Server**:
   ```sql
   -- View recent backups
   SELECT 
       database_name,
       backup_start_date,
       backup_finish_date,
       type,
       CASE type
           WHEN 'D' THEN 'Full'
           WHEN 'I' THEN 'Differential'
           WHEN 'L' THEN 'Transaction Log'
       END AS backup_type,
       physical_device_name
   FROM msdb.dbo.backupset bs
   INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
   ORDER BY backup_start_date DESC;
   ```

2. **Verify backup files**:
   ```powershell
   # Check default backup location
   $backupPath = Invoke-Sqlcmd -Query "SELECT SERVERPROPERTY('InstanceDefaultBackupPath') AS BackupPath" -ServerInstance "localhost"
   
   # List backup files
   Get-ChildItem -Path $backupPath.BackupPath -Filter "*.bak" | Select-Object Name, Length, LastWriteTime
   ```

3. **View current backup policy**:
   ```azurecli
   az sql server-arc backups-policy show \
       --name <arc-server-name> \
       --resource-group arcsql-lab-arc-rg
   ```

**Understanding Retention Policy:**

- Retention period determines how long backup files are kept
- Expired backups are automatically deleted
- Always maintains at least one full backup frequency plus retention days
- Example: 7-day retention with weekly full backup = ~14 days of backups kept

**Validation:**
- ✅ Backup policy configured successfully
- ✅ Retention period set appropriately
- ✅ Backup schedule matches business requirements
- ✅ First backup executed successfully (may take time)
- ✅ Backup history visible in `msdb.dbo.backupset`

**Troubleshooting:**

If backups are not running:
- Verify license type is **Paid** or **PAYG**
- Check that databases are in Full Recovery Model
- Ensure default backup path is accessible
- Verify NT AUTHORITY\SYSTEM has required permissions
- Review SQL Server error logs for backup failures
- Check extension logs for error messages
- Confirm retention period is not set to 0

**Additional Resources:**
- [Manage automated backups for SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/backup-local?view=sql-server-ver17)
- [SQL Server backup and restore](https://learn.microsoft.com/sql/relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases)
- [Recovery models in SQL Server](https://learn.microsoft.com/sql/relational-databases/backup-restore/recovery-models-sql-server)

---

### Module 11: Point-in-Time Restore (20 minutes) ⚠️ OPTIONAL - PREVIEW

> **Note:** This module is presented as a pair with Module 10 (Backup Management). Module 10 must be completed before starting this module.

Restore a database to a specific point in time using automated backups.

**Objectives:**
- Understand point-in-time restore capabilities
- Restore a database to a previous point in time
- Verify the restored database
- Understand restore limitations

**Prerequisites:**
- ✅ Module 10 completed (automated backups configured and running)
- ✅ At least one successful full backup completed
- ✅ Transaction log backups available for the restore window
- ✅ Database in Full Recovery Model

**Steps:**

#### Part A: Understanding Point-in-Time Restore (PITR)

1. **Review PITR capabilities**:
   - Restores database to any point in time within retention period
   - Creates a new database on the same instance
   - Uses automated backups from Module 10
   - Requires full backup + differential + transaction logs
   - Initiated from Azure portal or Azure CLI

2. **How PITR works**:
   - Azure orchestrates the restore from backup files
   - Extension performs native SQL Server restore operations
   - Full backup is restored first
   - Differential backup applied (if available)
   - Transaction logs applied up to specified point in time
   - New database created with specified name

3. **Important considerations**:
   - ⚠️ Source database must have automated backups enabled
   - ⚠️ Only backups taken by Azure extension can be used
   - ⚠️ Cannot restore to a different instance
   - ⚠️ Restored database created on same instance as source
   - ⚠️ Original database remains unchanged

#### Part B: Prepare for Restore

1. **Create test data** (to demonstrate restore to a point in time):
   ```sql
   -- Create a test database if needed
   USE master;
   GO
   IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'TestRestoreDB')
   BEGIN
       CREATE DATABASE TestRestoreDB;
   END
   GO
   
   -- Ensure Full Recovery Model
   ALTER DATABASE TestRestoreDB SET RECOVERY FULL;
   GO
   
   -- Create test table with timestamp
   USE TestRestoreDB;
   GO
   CREATE TABLE TestData (
       ID INT IDENTITY(1,1) PRIMARY KEY,
       DataValue NVARCHAR(100),
       CreatedDate DATETIME DEFAULT GETDATE()
   );
   GO
   
   -- Insert initial data
   INSERT INTO TestData (DataValue) VALUES ('Data before restore point');
   GO
   
   -- Force a transaction log backup
   -- Wait for automated backup or trigger manually
   ```

2. **Note the current time** (this will be your restore point):
   ```sql
   SELECT GETUTCDATE() AS CurrentUTCTime;
   -- Example output: 2024-11-10 16:30:00.000
   ```

3. **Insert more data** (after the restore point):
   ```sql
   -- Wait 5-10 minutes for transaction log backups to complete
   -- Then insert new data
   INSERT INTO TestData (DataValue) VALUES ('Data after restore point - should not appear in restored DB');
   GO
   ```

4. **Verify automated backups are available**:
   ```sql
   -- Check recent backups
   SELECT 
       database_name,
       backup_start_date,
       type,
       CASE type
           WHEN 'D' THEN 'Full'
           WHEN 'I' THEN 'Differential'  
           WHEN 'L' THEN 'Transaction Log'
       END AS backup_type
   FROM msdb.dbo.backupset
   WHERE database_name = 'TestRestoreDB'
   ORDER BY backup_start_date DESC;
   ```

#### Part C: Perform Point-in-Time Restore (Azure Portal)

1. **Navigate to Backups**:
   - Go to your SQL Server Arc resource
   - Select **Backups**

2. **Select database to restore**:
   - In the list of databases, find **TestRestoreDB**
   - Click **Restore** for that database

3. **Configure restore**:
   - **Source database**: TestRestoreDB (pre-populated)
   - **Point-in-time**: Select the UTC time you noted earlier
     - Use the date/time picker
     - Format: YYYY-MM-DD HH:MM:SS UTC
   - **New database name**: `TestRestoreDB_PITR`
   - Review the summary
   - Click **Create** or **Submit**

4. **Monitor restore progress**:
   - Restore operation appears in Azure portal notifications
   - Can take 5-30 minutes depending on database size
   - Monitor in **Activity log** or **Notifications** in Azure portal

#### Part D: Perform Point-in-Time Restore (Azure CLI)

```azurecli
# Set variables
$resourceGroup = "arcsql-lab-arc-rg"
$serverName = "<arc-server-name>"  # e.g., MyServer_MSSQLSERVER
$sourceDatabase = "TestRestoreDB"
$newDatabaseName = "TestRestoreDB_PITR"
$restorePointTime = "2024-11-10T16:30:00Z"  # Use your actual timestamp in ISO 8601 format

# Perform restore
az sql db-arc restore \
    --dest-name $newDatabaseName \
    --resource-group $resourceGroup \
    --name $sourceDatabase \
    --server $serverName \
    --time $restorePointTime
```

Example:

```azurecli
az sql db-arc restore \
    --dest-name "TestRestoreDB_PITR" \
    --resource-group "arcsql-lab-arc-rg" \
    --name "TestRestoreDB" \
    --server "MyServer_MSSQLSERVER" \
    --time "2024-11-10T16:30:00Z"
```

#### Part E: Verify Restored Database

1. **Check restore completion**:
   ```sql
   -- Verify new database exists
   SELECT name, create_date, state_desc 
   FROM sys.databases 
   WHERE name = 'TestRestoreDB_PITR';
   ```

2. **Verify data is from restore point**:
   ```sql
   -- Query restored database
   USE TestRestoreDB_PITR;
   GO
   
   SELECT * FROM TestData;
   -- Should only show data created BEFORE the restore point
   -- Should NOT show data created AFTER the restore point
   ```

3. **Compare with source database**:
   ```sql
   -- Query source database
   USE TestRestoreDB;
   GO
   
   SELECT * FROM TestData;
   -- Should show ALL data including data after restore point
   ```

4. **Verify restore information**:
   ```sql
   -- Check restore history
   SELECT 
       destination_database_name,
       restore_date,
       restore_type,
       user_name
   FROM msdb.dbo.restorehistory
   WHERE destination_database_name = 'TestRestoreDB_PITR'
   ORDER BY restore_date DESC;
   ```

#### Part F: Cleanup Test Database (Optional)

If you want to clean up the test databases:

```sql
USE master;
GO

-- Drop restored database
DROP DATABASE IF EXISTS TestRestoreDB_PITR;
GO

-- Optionally drop test database
DROP DATABASE IF EXISTS TestRestoreDB;
GO
```

**Understanding Restore Points:**

- Any point in time within the retention period is valid
- Must be after the last full backup
- Must be before the most recent transaction log backup
- Use UTC time format for Azure CLI
- Azure portal provides date/time picker for convenience

**Common Restore Scenarios:**

| Scenario | Solution |
|----------|----------|
| Accidental data deletion | Restore to time before deletion |
| Corrupted data | Restore to last known good state |
| Failed deployment | Restore to pre-deployment time |
| Testing/development | Create point-in-time copies for testing |

**Validation:**
- ✅ Point-in-time restore completed successfully
- ✅ New database created with specified name
- ✅ Restored database contains data only up to restore point
- ✅ Source database remains unchanged
- ✅ Restore history recorded in msdb

**Troubleshooting:**

If restore fails:
- Verify automated backups were taken for the database
- Ensure full backup exists before restore point
- Confirm transaction log backups cover the restore time range
- Check that restore point is within retention period
- Verify database was in Full Recovery Model at backup time
- Ensure sufficient disk space for restored database
- Review SQL Server error logs for restore errors
- Check Azure portal Activity Log for deployment errors

**Additional Resources:**
- [Point-in-time restore for SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/point-in-time-restore?view=sql-server-ver17)
- [Restore and recovery overview (SQL Server)](https://learn.microsoft.com/sql/relational-databases/backup-restore/restore-and-recovery-overview-sql-server)
- [Complete database restores (Full Recovery Model)](https://learn.microsoft.com/sql/relational-databases/backup-restore/complete-database-restores-full-recovery-model)

---

### Module 12: Lab Cleanup (10 minutes)

Remove all lab resources to avoid ongoing charges.

**Objectives:**
- Disconnect SQL Server from Azure Arc
- Uninstall Azure Connected Machine agent
- Delete Azure resources
- Verify complete cleanup

**Steps:**

1. **Run the cleanup script**:
   ```powershell
   cd ../scripts
   .\Cleanup-Lab.ps1 -SubscriptionId "<your-subscription-id>" -BaseName "arcsql-lab"
   ```

2. **Confirm cleanup actions** when prompted:
   - Review resources to be deleted
   - Type **YES** to confirm

3. **Manual cleanup** (if needed):
   
   a. **Disconnect SQL Server from Arc** (on-premises server):
   ```powershell
   # Uninstall Azure Connected Machine agent
   & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" disconnect --force-local-only
   
   # Uninstall agent
   & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" uninstall
   ```

   b. **Delete Azure resources**:
   ```powershell
   # Delete Arc resource group
   Remove-AzResourceGroup -Name "arcsql-lab-arc-rg" -Force
   
   # Delete monitoring resource group
   Remove-AzResourceGroup -Name "arcsql-lab-monitoring-rg" -Force
   ```

4. **Verify cleanup**:
   - Check Azure portal to confirm resource groups are deleted
   - On the on-premises server, verify Arc agent is uninstalled:
     ```powershell
     Get-Service -Name himds -ErrorAction SilentlyContinue
     # Should return nothing if uninstalled
     ```

**Validation:**
- ✅ SQL Server disconnected from Azure Arc
- ✅ Azure Connected Machine agent uninstalled
- ✅ All Azure resource groups deleted
- ✅ No Arc-related services running on-premises

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Arc agent installation fails
**Solution:**
- Verify network connectivity using `Test-ArcConnectivity.ps1`
- Check firewall rules allow outbound HTTPS (port 443)
- Ensure running PowerShell as Administrator
- Review logs: `%ProgramData%\AzureConnectedMachineAgent\Log\azcmagent.log`

#### Issue: SQL Server extension not auto-deploying
**Solution:**
- Verify SQL Server is installed and running
- Check that resource group doesn't have tag `ArcSQLServerExtensionDeployment = Disabled`
- Wait up to 30 minutes for auto-deployment
- Manually deploy extension using PowerShell (see Module 3)

#### Issue: BPA cannot be enabled (license type error)
**Solution:**
- Verify license type is set to **Paid** or **PAYG** (not LicenseOnly)
- Change license type in **Configuration** blade
- Wait a few minutes and try enabling BPA again

#### Issue: Policy remediation task fails
**Solution:**
- Verify managed identity has required permissions on Log Analytics workspace
- Check policy assignment parameters are correct
- Review remediation task logs in Azure Policy > Remediation
- Manually run remediation task again

#### Issue: Monitoring data not appearing
**Solution:**
- Verify license type is **Paid** or **PAYG**
- Check extension version is 1.1.2504.99 or later
- Ensure connectivity to `*.swedencentral.arcdataservices.com`
- Wait up to 15 minutes for data to appear
- Review extension logs on the server

#### Issue: Automated patching not enabled
**Solution:**
- Verify license type is **Paid** or **PAYG** (not LicenseOnly)
- Check that Windows Update service is running
- Ensure server has connectivity to Windows Update endpoints
- Review extension configuration for AutoPatchingSettings
- Check extension logs for error messages

#### Issue: Automated backups not running
**Solution:**
- Verify license type is **Paid** or **PAYG**
- Ensure databases are in Full Recovery Model
- Check that retention period is not set to 0
- Verify NT AUTHORITY\SYSTEM has required permissions
- Ensure default backup path is accessible
- Review SQL Server error logs for backup failures
- Check extension logs for error messages

#### Issue: Point-in-time restore fails
**Solution:**
- Verify automated backups were taken by Azure extension
- Ensure full backup exists before restore point
- Confirm transaction log backups cover the restore time range
- Check that restore point is within retention period
- Verify sufficient disk space for restored database
- Review SQL Server error logs for restore errors
- Check Azure portal Activity Log for deployment errors

---

## Additional Resources

### Microsoft Learn Documentation

**Core Features:**
- [SQL Server enabled by Azure Arc - Overview](https://learn.microsoft.com/sql/sql-server/azure-arc/overview)
- [Connect your SQL Server to Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/connect)
- [Manage licensing and billing](https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing)
- [Best practices assessment](https://learn.microsoft.com/sql/sql-server/azure-arc/assess)
- [Azure Policy for Arc SQL Server](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#sql-server)

**Optional Preview Features:**
- [Configure automatic updates for SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/update?view=sql-server-ver17)
- [Monitor SQL Server enabled by Azure Arc (preview)](https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17)
- [Manage automated backups (preview)](https://learn.microsoft.com/sql/sql-server/azure-arc/backup-local?view=sql-server-ver17)
- [Restore to a point-in-time (preview)](https://learn.microsoft.com/sql/sql-server/azure-arc/point-in-time-restore?view=sql-server-ver17)

### Tools and Scripts
- [Azure Arc Jumpstart](https://azurearcjumpstart.io/)
- [SQL Server Samples - Azure Arc](https://github.com/microsoft/sql-server-samples/tree/master/samples/manage/azure-arc)

### Pricing Information
- [SQL Server enabled by Azure Arc pricing](https://azure.microsoft.com/pricing/details/azure-arc/sqlserver/)
- [Azure Hybrid Benefit](https://azure.microsoft.com/pricing/hybrid-benefit/)

---

## Feedback and Support

If you encounter issues or have suggestions for improving this lab:

1. **Repository Issues**: [Open an issue on GitHub](https://github.com/microsoft/azure-arc-enabled-sql-server/issues)
2. **Microsoft Support**: [Azure Support](https://azure.microsoft.com/support/options/)
3. **Community Forums**: [Microsoft Q&A - Azure Arc](https://learn.microsoft.com/answers/tags/146/azure-arc)

---

## Lab Summary

Congratulations! You have completed the Azure Arc-enabled SQL Server hands-on lab.

**What you accomplished (core modules):**
- ✅ Deployed Azure infrastructure using Bicep
- ✅ Validated network connectivity to Azure Arc
- ✅ Onboarded on-premises Windows Server to Azure Arc
- ✅ Deployed Azure extension for SQL Server with auto-discovery
- ✅ Configured and transitioned SQL Server license types
- ✅ Enabled monitoring for SQL Server performance and health
- ✅ Ran Best Practices Assessment and reviewed recommendations
- ✅ Deployed Azure Policy for BPA at scale
- ✅ Successfully cleaned up all lab resources

**What you accomplished (optional preview modules):**
- ✅ Configured automated patching with maintenance windows
- ✅ Enabled advanced performance monitoring with detailed DMV metrics
- ✅ Set up automated backup management with custom schedules
- ✅ Performed point-in-time database restore

**Key takeaways:**
- Azure Arc extends Azure management to on-premises SQL Server
- Automatic discovery simplifies SQL Server inventory management
- Flexible licensing options (PAYG, Paid, LicenseOnly)
- Built-in monitoring and best practices assessment
- Azure Policy enables governance at scale
- Centralized management through Azure portal
- Preview features provide advanced lifecycle management capabilities

**Next steps:**
- Apply these concepts to your production environment
- Explore advanced monitoring and alerting
- Integrate with Microsoft Defender for Cloud
- Implement automated backup strategies for production databases
- Configure automated patching schedules aligned with maintenance windows
- Implement Microsoft Entra ID authentication

---

© Microsoft Corporation. Licensed under the Apache License, Version 2.0.
