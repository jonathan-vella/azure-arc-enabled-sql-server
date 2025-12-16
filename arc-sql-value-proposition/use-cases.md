# Azure Arc-enabled SQL Server: Use Cases

Version: v1.2025.12
Last updated: 2025-12-16

This document presents real-world scenarios where Azure Arc-enabled SQL Server delivers significant value, with both business context and technical implementation notes.

---

## Use Case 1: Hybrid Estate Visibility

### Scenario

A financial services organization operates 200+ SQL Server instances across three on-premises data centers, two co-location facilities, and development environments in AWS. The infrastructure team struggles to maintain accurate inventory, track versions, and identify security vulnerabilities across this distributed estate.

### Business Challenge

- Manual inventory takes weeks and is outdated upon completion
- No single view of SQL Server versions, editions, or patch levels
- Compliance audits require extensive manual data gathering
- Capacity planning relies on incomplete information

### Solution with Azure Arc

**Implementation approach**:
1. Deploy Azure Arc Connected Machine agent to all servers hosting SQL Server
2. Azure extension for SQL Server automatically discovers and catalogs instances
3. Azure Resource Graph provides queryable inventory across all environments

**Resulting capabilities**:

| Capability | Benefit |
|------------|---------|
| Automatic instance discovery | Eliminates manual inventory processes |
| Database-level metadata | Visibility into database count, size, recovery models |
| Version and edition tracking | Identify end-of-support versions instantly |
| Azure portal dashboards | Single view across all environments |
| Resource Graph queries | Custom reports and compliance evidence |

**Example Resource Graph query** - Find all SQL Server 2014 instances:
```kusto
resources
| where type == "microsoft.azurearcdata/sqlserverinstances"
| where properties.version startswith "13."
| project name, resourceGroup, location, properties.version, properties.edition
```

---

## Use Case 2: Extended Security Updates (ESU) for End-of-Support SQL Server

### Scenario

A healthcare organization runs 50 SQL Server 2012 and 2014 instances supporting legacy clinical applications. These applications cannot be immediately migrated due to vendor dependencies, but the organization must maintain security compliance.

### Business Challenge

- SQL Server 2012 and 2014 are past end-of-support
- Traditional ESU purchases require upfront commitment
- No visibility into which instances need priority attention
- Limited budget for immediate modernization

### Solution with Azure Arc

**Implementation approach**:
1. Connect SQL Server instances to Azure Arc
2. ESU access is automatically enabled through Arc connection
3. Best Practices Assessment identifies configuration risks
4. Migration assessment provides modernization roadmap

**Value delivered**:

| Aspect | Without Arc | With Arc |
|--------|-------------|----------|
| ESU access | Purchase ESU licenses separately | Included with Arc connection |
| Security patches | Manual download and deployment | Automated through extension |
| Additional features | ESU only | Full Arc capabilities (monitoring, assessment, Defender) |
| Migration planning | Separate assessment tools | Integrated migration assessment |

**Transition path**:
```
┌────────────────┐     ┌────────────────┐     ┌────────────────┐
│  SQL 2012/2014 │     │  SQL 2019/2022 │     │   Azure SQL    │
│  + Arc + ESU   │ ──▶ │    on-prem     │ ──▶ │  (when ready)  │
│                │     │    via Arc     │     │                │
└────────────────┘     └────────────────┘     └────────────────┘
     Secure now           Upgrade path          Cloud migration
```

---

## Use Case 3: Pay-As-You-Go Licensing Flexibility

### Scenario

A retail company operates SQL Server instances supporting seasonal e-commerce workloads. During holiday periods, they scale up significantly, but for 8 months of the year, capacity utilization is below 40%.

### Business Challenge

- Traditional licensing requires paying for peak capacity year-round
- Development and test environments duplicate production licensing costs
- Budget constraints limit the ability to scale for peak periods
- CapEx approval cycles slow down capacity additions

### Solution with Azure Arc

**Implementation approach**:
1. Convert seasonal workloads to PAYG licensing through Azure Arc
2. Maintain traditional licenses for stable, high-utilization workloads
3. Use PAYG for all dev/test environments
4. Monitor usage through Azure billing

**Licensing optimization strategy**:

| Workload Type | Licensing Approach | Rationale |
|---------------|-------------------|-----------|
| Production (stable, high utilization) | Traditional (Paid) | Predictable, cost-effective at scale |
| Production (seasonal) | PAYG | Pay only during peak periods |
| Development | PAYG | Minimal cost during active development |
| Test | PAYG | Spin up/down as needed |
| Disaster recovery (cold standby) | PAYG | Near-zero cost when idle |

**PAYG activation** (PowerShell):
```powershell
# Modify license type to PAYG
$settings = @{
    LicenseType = 'PAYG'
}
Set-AzConnectedMachineExtension -ResourceGroupName $rg `
    -MachineName $serverName -Name 'WindowsAgent.SqlServer' `
    -Settings $settings
```

---

## Use Case 4: Unified Security and Compliance Posture

### Scenario

A government contractor must demonstrate continuous security monitoring and vulnerability management across all database systems to maintain compliance certifications. Their SQL Server instances span classified and unclassified networks with different security requirements.

### Business Challenge

- Multiple security tools with no unified view
- Manual vulnerability scanning and reporting
- Inconsistent security baselines across environments
- Audit evidence gathering is time-consuming

### Solution with Azure Arc

**Implementation approach**:
1. Enable Microsoft Defender for SQL through Azure Arc
2. Configure Microsoft Entra ID authentication for SQL Server 2022+ instances
3. Implement Azure RBAC for consistent access control
4. Enable Best Practices Assessment for configuration drift detection

**Security capabilities matrix**:

| Capability | Implementation | Compliance Benefit |
|------------|----------------|-------------------|
| Vulnerability assessment | Defender for SQL | Continuous scanning with remediation guidance |
| Threat detection | Defender for SQL | Anomaly detection, SQL injection alerts |
| Identity management | Microsoft Entra ID | Centralized authentication, MFA support |
| Access control | Azure RBAC | Auditable, granular permissions |
| Configuration baseline | Best Practices Assessment | Drift detection, hardening recommendations |
| Audit logging | Azure Monitor integration | Centralized, tamper-evident logs |

**Defender for SQL integration**:
```
┌─────────────────────────────────────────────────────────────┐
│                    Security Operations                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  Defender   │  │   Sentinel  │  │   Alerts    │         │
│  │  for Cloud  │  │    SIEM     │  │   & Actions │         │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │
│         │                │                │                 │
│         └────────────────┼────────────────┘                 │
│                          │                                  │
└──────────────────────────┼──────────────────────────────────┘
                           │
              ┌────────────┴────────────┐
              │   Azure Arc-enabled     │
              │      SQL Server         │
              │  (all environments)     │
              └─────────────────────────┘
```

---

## Use Case 5: Cloud Migration Readiness Assessment

### Scenario

An insurance company has committed to a cloud-first strategy with a 3-year timeline to migrate 80% of workloads to Azure. They operate 150 SQL Server instances and need to prioritize migration candidates, identify blockers, and plan target architectures.

### Business Challenge

- No systematic way to assess all instances for cloud readiness
- Unknown feature compatibility with Azure SQL options
- Manual sizing exercises are time-consuming and error-prone
- Need to balance migration urgency with business risk

### Solution with Azure Arc

**Implementation approach**:
1. Connect all SQL Server instances to Azure Arc
2. Enable migration assessment feature
3. Generate readiness reports per instance
4. Use recommendations to build migration waves

**Assessment output provides**:

| Assessment Area | Details Provided |
|-----------------|-----------------|
| Cloud readiness | Ready, Ready with conditions, Not ready |
| Blocker identification | Features not supported in Azure SQL |
| Target recommendations | SQL Database, Managed Instance, or SQL VM |
| Sizing guidance | Compute, storage, and performance tier recommendations |
| Risk factors | Dependencies, linked servers, CLR usage |
| Remediation steps | Actions to resolve compatibility issues |

**Migration wave planning**:
```
Wave 1 (Months 1-6)      Wave 2 (Months 7-12)     Wave 3 (Months 13-24)
┌─────────────────┐     ┌─────────────────┐      ┌─────────────────┐
│ Ready instances │     │  Ready with     │      │  Complex apps   │
│ Low complexity  │     │  conditions     │      │  Refactoring    │
│ Non-critical    │     │  Medium risk    │      │  required       │
│                 │     │                 │      │                 │
│ → Azure SQL DB  │     │ → SQL Managed   │      │ → SQL VM or     │
│                 │     │   Instance      │      │   remain hybrid │
└─────────────────┘     └─────────────────┘      └─────────────────┘
```

---

## Implementation Patterns Across Use Cases

### Common First Steps

1. **Pilot deployment**: Start with non-production or low-risk instances
2. **Validate connectivity**: Ensure outbound HTTPS access to Azure endpoints
3. **Establish governance**: Define tagging standards and resource group structure
4. **Enable incrementally**: Add features (monitoring, Defender, assessment) progressively

### Success Factors

| Factor | Recommendation |
|--------|----------------|
| Stakeholder alignment | Include security, operations, and finance teams early |
| Change management | Communicate the "why" to server administrators |
| Monitoring baseline | Establish metrics before and after Arc deployment |
| Documentation | Maintain runbooks for common Arc operations |

---

## Next Steps

- Review [Security Benefits](security-benefits.md) for detailed security implementation guidance
- Explore the [Hands-on Lab](../arc-sql-hands-on-lab/) for practical experience
- See [Business Case](business-case.md) for additional value analysis

---

## Related Resources

- [Migration assessment documentation](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/migration-assessment)
- [Best Practices Assessment](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/assess)
- [Extended Security Updates](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/extended-security-updates)
- [Manage licensing and billing](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/manage-license-billing)
