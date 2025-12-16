# Content Inventory and Issues Log

Version: v3.1
Generated: 2025-12-16
Last updated: 2025-12-16
Status: **Peer Review Complete + Consolidation Applied ✅**

## Summary

| Category | Count | Notes |
|----------|-------|-------|
| Total Files | 43 | Reduced from 45 after consolidation |
| Markdown (.md) | 27 | Documentation files |
| PowerShell (.ps1) | 8 | Scripts |
| Bicep (.bicep) | 2 | Infrastructure |
| JSON (.json) | 6 | Configuration |

## Peer Review Summary (December 2025)

### Issues Found and Fixed ✅
- ✅ Fixed "Azure AD" → "Microsoft Entra ID" in `Create-ArcServicePrincipal.ps1`
- ✅ Fixed `docs.microsoft.com` → `learn.microsoft.com` in `PREREQUISITES.md`
- ✅ All MS Learn URLs use `view=sql-server-ver17` (current)
- ✅ All documentation has consistent version metadata (v1.2025.12)

### Content Verified Against MS Learn ✅
- Feature availability tables match MS Learn documentation
- ESU information current (SQL 2012 ESU ended July 2025, SQL 2014 ongoing)
- SQL Server 2025 references are accurate
- Unsupported configurations list is complete
- Least privilege mode documentation is current
- Windows Server 2012/2012 R2 limitations documented correctly

### Consolidation Completed ✅
- ✅ `arc-sql-data-collection/README.md`: Reduced from 150 → 45 lines; links to MS Learn for detailed data
- ✅ `arc-sql-activate-pcore-license/`: Merged into `arc-sql-modify-license-type/` and folder deleted
- ✅ Updated main README.md to reflect merged licensing content

---

## Completed Actions (All Sessions)

- ✅ Deleted `temp/` folder (duplicates and orphan files)
- ✅ Deleted `arc-sql-namespace-migration/` folder (no longer required)
- ✅ Fixed typos in `arc-sql-activate-pcore-license/README.md`
- ✅ Renamed `activate-pcore-license.md` → `activate-pcore-license.ps1`
- ✅ Deleted deprecated scripts using AzureAD module (3 folders)
- ✅ Consolidated `arc-sql-activate-pcore-license/` into `arc-sql-modify-license-type/`
- ✅ Simplified `arc-sql-data-collection/README.md` with MS Learn links
- ✅ Updated all documentation with "Last updated" dates
- ✅ Updated MS Learn URLs (docs.microsoft.com → learn.microsoft.com)
- ✅ Updated terminology (Azure AD → Microsoft Entra ID)

---

## Content Inventory by Folder

### ✅ KEEP - High Value, Unique Content

| File | Size | Assessment | Recommendation |
|------|------|------------|----------------|
| `arc-sql-hands-on-lab/README.md` | 66.8 KB | Comprehensive hands-on lab with step-by-step instructions | **KEEP** - Unique value, actionable |
| `arc-sql-hands-on-lab/bicep/main.bicep` | 4.2 KB | Infrastructure template for lab | **KEEP** - Actionable |
| `arc-sql-hands-on-lab/bicep/deploy.ps1` | 7.1 KB | Deployment script | **KEEP** - Actionable |
| `arc-sql-hands-on-lab/lab-commands.ps1` | 31.0 KB | Lab command reference | **KEEP** - Actionable |
| `arc-sql-hands-on-lab/scripts/Test-ArcConnectivity.ps1` | 14.7 KB | Connectivity testing tool | **KEEP** - Actionable |
| `arc-sql-hands-on-lab/scripts/Create-ArcServicePrincipal.ps1` | 11.0 KB | Service principal creation | **KEEP** - Actionable |
| `arc-sql-hands-on-lab/scripts/Cleanup-Lab.ps1` | 10.9 KB | Lab cleanup script | **KEEP** - Actionable |
| `arc-sql-modify-license-type/modify-arc-sql-license-type.ps1` | 17.4 KB | Official MS script | **KEEP** - From Microsoft |
| `arc-sql-monitoring/set-feature-flags.ps1` | 7.4 KB | Feature flag configuration | **KEEP** - Unique functionality |
| `arc-sql-report-reclass-extension-status/Get-SQLAzureArcReclassReport.ps1` | 7.2 KB | Reporting script | **KEEP** - Unique functionality |
| `arc-sql-value-proposition/` (all files) | ~54 KB | Business value documentation | **KEEP** - Unique perspective |

### ⚠️ UPDATE - Needs Corrections

| File | Size | Issues Found | Action Required |
|------|------|--------------|-----------------|
| `arc-sql-faq/README.md` | 28.7 KB | Some outdated info, duplicates MS Learn content | **UPDATE** - Consolidate unique Q&A only |
| `arc-sql-best-practice-assessment/README.md` | 6.7 KB | Good but has some overlap with MS docs | **UPDATE** - Focus on unique guidance |
| `arc-sql-activate-pcore-license/README.md` | 2.7 KB | Typos: "scahedule", "selecetd" | **UPDATE** - Fix typos |
| `README.md` | 12.7 KB | Good overview but some info duplicates MS docs | **UPDATE** - Link to MS docs for details |

### 🔗 LINK - Replace with Links to MS Docs

| File | Size | Reason | Recommendation |
|------|------|--------|----------------|
| `arc-sql-data-collection/README.md` | 5.7 KB | Largely duplicates MS docs content | **CONSOLIDATE** - Keep unique summary, link to docs |
| `arc-sql-connectivity/README.md` | 4.0 KB | Mostly describes azcmagent check | **LINK** - Add value with troubleshooting tips |

### 🗑️ DELETE - Duplicate or Obsolete

| File | Size | Reason | Status |
|------|------|--------|--------|
| ~~`temp/_index.md`~~ | ~1.7 KB | Duplicate | ✅ DELETED |
| ~~`temp/ArcEndpointCheck.ps1`~~ | ~8.1 KB | Duplicate | ✅ DELETED |
| ~~`temp/ArcEndpointCheck.png`~~ | N/A | Orphan media file | ✅ DELETED |
| ~~`arc-sql-activate-pcore-license/activate-pcore-license.md`~~ | ~0.8 KB | Was misnamed .ps1 file | ✅ RENAMED to .ps1 |
| ~~`arc-sql-namespace-migration/migrate-to-azure-arc-data.ps1`~~ | ~2.7 KB | Legacy namespace migration | ✅ DELETED - No longer required |

---

## Issues Log

### Critical Issues

| # | File | Issue | Status |
|---|------|-------|--------|
| 1 | ~~`arc-sql-activate-pcore-license/README.md`~~ | ~~Typo: "scahedule" should be "schedule"~~ | ✅ FIXED |
| 2 | ~~`arc-sql-activate-pcore-license/README.md`~~ | ~~Typo: "selecetd" should be "selected"~~ | ✅ FIXED |
| 3 | ~~`temp/` folder~~ | ~~Contains orphan/duplicate files~~ | ✅ DELETED |
| 4 | ~~`arc-sql-namespace-migration/`~~ | Legacy script | ✅ DELETED - No longer required |

### Content Accuracy Issues

| # | File | Issue | Status |
|---|------|-------|--------|
| 1 | `arc-sql-faq/README.md` | 30-day disconnection limit | ✅ VERIFIED - Accurate |
| 2 | `arc-sql-faq/README.md` | ESU timeline statements | ✅ VERIFIED - Updated |
| 3 | `arc-sql-value-proposition/` | Feature availability tables | ✅ REVIEWED - Current |

### Duplicate Content Analysis

| Repository Content | Duplicates MS Learn | Recommendation |
|-------------------|---------------------|----------------|
| Supported regions list | Yes - identical | Link instead of duplicate |
| Unsupported configurations | Yes - identical | Link instead of duplicate |
| Prerequisites list | Yes - identical | Link instead of duplicate |
| Feature availability tables | Yes - mostly identical | Link instead of duplicate |
| Data collection categories | Yes - detailed docs exist | Summarize and link |

---

## Script Status

### Scripts from Microsoft Official Repository

| Script | Source | Status |
|--------|--------|--------|
| `modify-arc-sql-license-type.ps1` | Microsoft sql-server-samples | ✅ Current v3.0.5 |

### Custom Scripts (Repository-Specific)

| Script | Purpose | Status | Recommendation |
|--------|---------|--------|----------------|
| `Get-SQLAzureArcReclassReport.ps1` | SQL reclass reporting | ✅ Unique | **KEEP** |
| `set-feature-flags.ps1` | Feature flag config | ✅ Unique | **KEEP** |
| `Test-ArcConnectivity.ps1` | Connectivity testing | ✅ Unique | **KEEP** |
| `Create-ArcServicePrincipal.ps1` | Service principal creation | ✅ Unique | **KEEP** |
| `Cleanup-Lab.ps1` | Lab cleanup | ✅ Unique | **KEEP** |
| `deploy.ps1` | Bicep deployment | ✅ Unique | **KEEP** |
| `lab-commands.ps1` | Lab reference | ✅ Unique | **KEEP** |
| `migrate-to-azure-arc-data.ps1` | Namespace migration | ✅ Useful for legacy | **KEEP** - MS Learn still references |
| ~~`ArcEndpointCheck.ps1` (temp/)~~ | ~~Endpoint checking~~ | 🗑️ Duplicate | ✅ DELETED |

---

## Recommended Actions (Priority Order)

### High Priority ✅ COMPLETE

1. ~~**Delete `temp/` folder**~~ - ✅ DONE
2. ~~**Fix typos in `arc-sql-activate-pcore-license/README.md`**~~ - ✅ DONE
3. ~~**Consolidate `activate-pcore-license.md` into `README.md`**~~ - ✅ Renamed to .ps1

### Medium Priority ✅ COMPLETE

4. ~~**Review `arc-sql-namespace-migration/`**~~ - ✅ DELETED (no longer required)
5. **`arc-sql-faq/README.md`** - ✅ REVIEWED (content provides value-added Q&A with links to docs)
6. **`arc-sql-data-collection/README.md`** - ✅ REVIEWED (comprehensive with unique detail)

### Low Priority ✅ COMPLETE

7. ~~**Review all feature availability statements**~~ - ✅ Aligned with current MS docs
8. ~~**Add "Last verified against MS Learn" dates**~~ - ✅ All docs have "Last updated" dates
9. **Consider adding CHANGELOG.md** - Optional future enhancement

---

## Content Value Assessment

### High Value (Keep As-Is or Minor Updates)

- **`arc-sql-hands-on-lab/`**: Complete lab environment with Bicep, scripts, step-by-step guides
- **`arc-sql-value-proposition/`**: Business case, security benefits, use cases - unique perspective
- **`arc-sql-modify-license-type/`**: Official Microsoft script with comprehensive README
- **Custom scripts**: Reporting, connectivity testing, service principal creation

### Medium Value (Update/Consolidate)

- **`arc-sql-faq/`**: Good Q&A but some overlap with MS docs
- **`arc-sql-best-practice-assessment/`**: Useful at-scale guidance
- **`arc-sql-videos/`** and **`arc-sql-presentation-files/`**: Learning resources

### Low Value (Consider Removal/Linking)

- ~~**`temp/`**~~: ✅ DELETED
- ~~**`arc-sql-namespace-migration/`**~~: ✅ DELETED - No longer required

---

## Files Requiring No Changes

| File | Reason |
|------|--------|
| `.github/instructions/*.md` | Copilot instruction files - internal use |
| `.github/copilot-instructions.md` | Repository instructions - internal use |
| `.github/workflows/link-check-config.json` | CI/CD config - internal use |
| `arc-sql-hands-on-lab/bicep/modules/log-analytics.bicep` | Lab infrastructure |
| `arc-sql-hands-on-lab/*.example.json` | Example files for lab |
| `TEMPLATE-FILES.md` | Template reference |
