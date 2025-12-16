# Azure Arc-enabled SQL Server Architecture Diagrams

Version: v1.2025.12
Last updated: 2025-12-16

This document contains architecture diagrams illustrating the value and capabilities of Azure Arc-enabled SQL Server.

---

## Management Architecture: Before and After Azure Arc

### Before: Fragmented Management

```mermaid
flowchart TB
    subgraph OnPrem["On-Premises Data Center"]
        SQL1[(SQL Server 1)]
        SQL2[(SQL Server 2)]
        SCOM[SCOM Monitoring]
        LocalAuth[Local Accounts]
    end
    
    subgraph Edge["Edge Location"]
        SQL3[(SQL Server 3)]
        EdgeMon[Edge Monitoring Tool]
        EdgeAuth[Local Accounts]
    end
    
    subgraph OtherCloud["Other Cloud Provider"]
        SQL4[(SQL Server 4)]
        CloudMon[Cloud-Native Monitoring]
        CloudAuth[Cloud IAM]
    end
    
    Admin1[Admin Team 1] --> SCOM
    Admin2[Admin Team 2] --> EdgeMon
    Admin3[Admin Team 3] --> CloudMon
    
    style OnPrem fill:#f9f9f9,stroke:#666
    style Edge fill:#f9f9f9,stroke:#666
    style OtherCloud fill:#f9f9f9,stroke:#666
```

**Challenges:**
- Multiple monitoring tools with no unified view
- Separate identity systems per environment
- Manual inventory and compliance tracking
- Inconsistent security policies

---

### After: Unified Azure Control Plane

```mermaid
flowchart TB
    subgraph Azure["Azure Control Plane"]
        Portal[Azure Portal]
        RBAC[Azure RBAC]
        Policy[Azure Policy]
        Monitor[Azure Monitor]
        Defender[Defender for Cloud]
        Graph[Resource Graph]
    end
    
    subgraph OnPrem["On-Premises Data Center"]
        Arc1[Arc Agent]
        SQL1[(SQL Server 1)]
        SQL2[(SQL Server 2)]
        Arc1 --- SQL1
        Arc1 --- SQL2
    end
    
    subgraph Edge["Edge Location"]
        Arc2[Arc Agent]
        SQL3[(SQL Server 3)]
        Arc2 --- SQL3
    end
    
    subgraph OtherCloud["Other Cloud Provider"]
        Arc3[Arc Agent]
        SQL4[(SQL Server 4)]
        Arc3 --- SQL4
    end
    
    Arc1 -->|Outbound HTTPS| Azure
    Arc2 -->|Outbound HTTPS| Azure
    Arc3 -->|Outbound HTTPS| Azure
    
    Admin[Unified Admin Team] --> Portal
    
    style Azure fill:#0078d4,stroke:#005a9e,color:#fff
    style Portal fill:#50e6ff,stroke:#0078d4
    style RBAC fill:#50e6ff,stroke:#0078d4
    style Policy fill:#50e6ff,stroke:#0078d4
    style Monitor fill:#50e6ff,stroke:#0078d4
    style Defender fill:#50e6ff,stroke:#0078d4
    style Graph fill:#50e6ff,stroke:#0078d4
```

**Benefits:**
- Single pane of glass for all SQL instances
- Unified identity with Microsoft Entra ID
- Automated inventory via Resource Graph
- Consistent policies across all environments

---

## Security Integration Architecture

```mermaid
flowchart LR
    subgraph SQLServers["SQL Server Instances"]
        SQL1[(On-Prem SQL)]
        SQL2[(Edge SQL)]
        SQL3[(Multi-Cloud SQL)]
    end
    
    subgraph ArcLayer["Azure Arc Layer"]
        Agent1[Arc Agent + SQL Extension]
        Agent2[Arc Agent + SQL Extension]
        Agent3[Arc Agent + SQL Extension]
    end
    
    subgraph AzureSecurity["Azure Security Services"]
        Defender[Microsoft Defender for SQL]
        Entra[Microsoft Entra ID]
        Purview[Microsoft Purview]
        Sentinel[Microsoft Sentinel]
    end
    
    subgraph SecOps["Security Operations"]
        Alerts[Security Alerts]
        Vuln[Vulnerability Reports]
        Compliance[Compliance Dashboard]
    end
    
    SQL1 --> Agent1
    SQL2 --> Agent2
    SQL3 --> Agent3
    
    Agent1 --> Defender
    Agent2 --> Defender
    Agent3 --> Defender
    
    Agent1 --> Entra
    Agent2 --> Entra
    Agent3 --> Entra
    
    Defender --> Alerts
    Defender --> Vuln
    Defender --> Sentinel
    Purview --> Compliance
    
    style AzureSecurity fill:#0078d4,stroke:#005a9e,color:#fff
    style Defender fill:#ff4444,stroke:#cc0000,color:#fff
    style Entra fill:#50e6ff,stroke:#0078d4
    style Purview fill:#742774,stroke:#4a0f4a,color:#fff
```

**Security capabilities:**
- **Defender for SQL**: Threat detection, vulnerability assessment, anomaly alerts
- **Microsoft Entra ID**: Centralized authentication, MFA, conditional access
- **Microsoft Purview**: Data discovery, classification, governance policies
- **Microsoft Sentinel**: SIEM integration for security event correlation

---

## Licensing Model Comparison

```mermaid
flowchart TB
    subgraph Traditional["Traditional Licensing"]
        direction TB
        TradPurchase[Upfront License Purchase]
        TradSA[Software Assurance Optional]
        TradCost[Fixed Cost Regardless of Usage]
        
        TradPurchase --> TradSA --> TradCost
    end
    
    subgraph PAYG["Pay-As-You-Go via Arc"]
        direction TB
        PAYGConnect[Connect to Azure Arc]
        PAYGUsage[Hourly Billing Based on Usage]
        PAYGFlex[Scale Up/Down Anytime]
        
        PAYGConnect --> PAYGUsage --> PAYGFlex
    end
    
    subgraph Hybrid["Hybrid Approach"]
        direction TB
        HybStable[Traditional for Stable Workloads]
        HybVariable[PAYG for Variable Workloads]
        HybOptimize[Optimized Cost Structure]
        
        HybStable --> HybOptimize
        HybVariable --> HybOptimize
    end
    
    style Traditional fill:#ffcc00,stroke:#cc9900
    style PAYG fill:#00cc66,stroke:#009944
    style Hybrid fill:#0078d4,stroke:#005a9e,color:#fff
```

---

## License Type Transitions

```mermaid
stateDiagram-v2
    [*] --> LicenseOnly: Initial Setup
    LicenseOnly --> Paid: Bring Your License
    LicenseOnly --> PAYG: Enable Billing
    Paid --> PAYG: Switch to Consumption
    PAYG --> Paid: Switch to BYOL
    
    note right of LicenseOnly
        Evaluation, Dev/Test
        No Azure billing
    end note
    
    note right of Paid
        Existing SA licenses
        Azure management included
    end note
    
    note right of PAYG
        Hourly billing
        No upfront commitment
    end note
```

---

## Data Flow Architecture

```mermaid
flowchart TB
    subgraph OnPremises["Customer Environment"]
        SQL[(SQL Server)]
        Extension[SQL Server Extension]
        Agent[Arc Connected Machine Agent]
        
        SQL --> Extension
        Extension --> Agent
    end
    
    subgraph AzureEndpoints["Azure Endpoints (Outbound Only)"]
        HIS[his.arc.azure.com]
        GC[guestconfiguration.azure.com]
        ArcData[arcdataservices.com]
        AAD[login.microsoftonline.com]
        ARM[management.azure.com]
    end
    
    subgraph AzureServices["Azure Services"]
        ResourceMgr[Azure Resource Manager]
        LogAnalytics[Log Analytics]
        DefenderSvc[Defender for Cloud]
        MonitorSvc[Azure Monitor]
    end
    
    Agent -->|HTTPS 443| HIS
    Agent -->|HTTPS 443| GC
    Agent -->|HTTPS 443| ArcData
    Agent -->|HTTPS 443| AAD
    Agent -->|HTTPS 443| ARM
    
    HIS --> ResourceMgr
    ArcData --> LogAnalytics
    ArcData --> DefenderSvc
    ArcData --> MonitorSvc
    
    style OnPremises fill:#f0f0f0,stroke:#666
    style AzureEndpoints fill:#e6f3ff,stroke:#0078d4
    style AzureServices fill:#0078d4,stroke:#005a9e,color:#fff
```

**Key points:**
- All connections are **outbound only** (no inbound firewall rules required)
- Communication over **HTTPS port 443**
- Data stays in customer environment; only metadata and telemetry sent to Azure
- Supports proxy servers and private endpoints

---

## Modernization Journey

```mermaid
journey
    title SQL Server Modernization with Azure Arc
    section Connect
      Deploy Arc Agent: 5: IT Admin
      Discover SQL Instances: 5: IT Admin
      View Inventory in Portal: 5: IT Admin
    section Assess
      Run Best Practices Assessment: 4: DBA
      Enable Migration Assessment: 4: DBA
      Review Security Posture: 4: Security
    section Optimize
      Enable Monitoring: 4: DBA
      Configure PAYG Licensing: 3: IT Admin
      Integrate Defender: 4: Security
    section Migrate (Optional)
      Plan Migration Waves: 3: Architect
      Migrate Ready Workloads: 3: DBA
      Maintain Hybrid Estate: 4: IT Admin
```

---

## Feature Availability by Environment

```mermaid
flowchart LR
    subgraph Features["Azure Arc Features"]
        Inventory[Inventory & Discovery]
        BPA[Best Practices Assessment]
        Migration[Migration Assessment]
        Monitoring[Performance Monitoring]
        Defender[Defender for SQL]
        PAYG[PAYG Licensing]
        ESU[Extended Security Updates]
        Entra[Entra ID Auth]
    end
    
    subgraph Environments["All Environments"]
        OnPrem[On-Premises]
        Edge[Edge Sites]
        MultiCloud[Other Clouds]
        AVS[Azure VMware Solution]
    end
    
    Features --> Environments
    
    style Features fill:#0078d4,stroke:#005a9e,color:#fff
    style Environments fill:#00cc66,stroke:#009944,color:#fff
```

**Consistent capabilities across:**
- On-premises data centers
- Edge and branch locations
- AWS, GCP, or other cloud providers
- Azure VMware Solution

---

*These diagrams render automatically in GitHub, Azure DevOps, and other Markdown viewers that support Mermaid.*
