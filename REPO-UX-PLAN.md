# Repository UX Improvement Plan

Version: v1.2025.12  
Last updated: 2025-12-16

---

## Overview

This document outlines the work required to make the **SQL Server enabled by Azure Arc**
repository more user-friendly for IT admins, partners, and SQL engineers while staying
accurate and consistent with Microsoft Learn.

---

## Constraints (enforce during all edits)

| ID | Constraint |
|----|------------|
| C1 | Only implement what is described; do not invent new features, tools, pages, or workflows |
| C2 | Prefer task-first navigation for new visitors |
| C3 | Preserve the repo's current folder structure unless a change is explicitly requested |
| C4 | Do not add hard-coded custom colors, themes, or fonts |
| C5 | Keep all markdown line lengths to **120 characters max** |
| C6 | Every markdown file must include metadata immediately after the H1 |
| C7 | Use fenced code blocks with language identifiers |
| C8 | Use `learn.microsoft.com` links (not `docs.microsoft.com`); prefer `view=sql-server-ver17` |
| C9 | Use terminology: **Microsoft Entra ID** (not "Azure AD" or "AAD") |
| C10 | Treat billing/licensing changes as high-risk: add clear callouts |
| C11 | Mark preview features with ⚠️ and link to [preview terms][preview-terms] |
| C12 | Use GitHub-flavored callouts: `> [!NOTE]`, `> [!IMPORTANT]`, `> [!WARNING]` |
| C13 | All internal links must resolve; broken links are blocking |
| C14 | Files that mostly duplicate Microsoft Learn content should be kept short and link out |
| C15 | Use reference-style links for long URLs to stay under 120 characters |
| C16 | Every file ends with a single newline |

[preview-terms]: https://azure.microsoft.com/support/legal/preview-supplemental-terms/

---

## Metadata format

Insert immediately after the H1 heading in every markdown file:

```markdown
# Document Title

Version: v1.2025.12  
Last updated: 2025-12-16
```

- The version is a date-based identifier (`v1.YYYY.MM`).
- All files share the same version when bulk-updated; increment on future passes.

---

## Deliverables

### 1. Root README – Task-first landing page

**Goal:** A new visitor can pick a task and reach the right doc in two clicks or less.

#### 1.1 Add "Most common tasks" strip (3–4 links)

Place near the top, immediately after the intro paragraph:

```markdown
## 🚀 Most common tasks

| Task | Link |
|------|------|
| Onboard a server to Azure Arc | [Onboarding guide](arc-sql-hands-on-lab/README.md#module-2) |
| Change license type (PAYG ↔ Paid) | [License management](arc-sql-modify-license-type/README.md) |
| Enable Best Practices Assessment | [BPA setup](arc-sql-best-practice-assessment/README.md) |
| Troubleshoot connectivity | [Connectivity guide](arc-sql-connectivity/README.md) |
```

#### 1.2 Add "Start here" navigation panel

Use the following section order; each item gets:

- One primary internal link (folder README or key doc)
- Optional: up to 2 supporting links
- A one-sentence description

| # | Section | Primary link | Description |
|---|---------|--------------|-------------|
| 1 | Get started / prerequisites | `arc-sql-hands-on-lab/PREREQUISITES.md` | What you need before onboarding |
| 2 | Onboard Azure Arc servers | `arc-sql-hands-on-lab/README.md#module-2` | Connect on-premises servers to Azure Arc |
| 3 | Install / configure SQL extension | `arc-sql-hands-on-lab/README.md#module-3` | Deploy the Azure extension for SQL Server |
| 4 | Licensing (PAYG / Paid / ESU) | `arc-sql-modify-license-type/README.md` | Manage license types and billing |
| 5 | Best Practices Assessment | `arc-sql-best-practice-assessment/README.md` | Run and review SQL best practices |
| 6 | Monitoring / feature flags | `arc-sql-monitoring/README.md` | Enable advanced monitoring and feature flags |
| 7 | Reporting / audits | `arc-sql-report-reclass-extension-status/README.md` | Generate compliance and status reports |
| 8 | Hands-on lab | `arc-sql-hands-on-lab/README.md` | End-to-end guided lab |
| 9 | Troubleshooting / connectivity | `arc-sql-connectivity/README.md` | Diagnose and fix connectivity issues |
| 10 | Reference (FAQ, videos, presentations) | `arc-sql-faq/README.md` | FAQ, videos, slide decks |

#### 1.3 Add badges (optional, lightweight)

```markdown
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white)
![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=microsoft-azure&logoColor=white)
![Last updated](https://img.shields.io/badge/updated-2025--12-blue)
```

---

### 2. Folder README template

Standardize each folder's README with the following sections (omit sections that don't apply):

```markdown
# Folder Title

Version: v1.2025.12  
Last updated: 2025-12-16

## Overview

One paragraph explaining what this folder contains and why it matters.

## When to use

Bullet list of scenarios where this content applies.

## Prerequisites

- Prerequisite 1
- Prerequisite 2

## Quick start

Minimal command or steps to get started:

```powershell
# Example command
```

## Examples

### Example 1: Short title

Description and code.

### Example 2: Short title

Description and code.

## Troubleshooting

| Symptom | Cause | Resolution |
|---------|-------|------------|
| ... | ... | ... |

## Related documentation

- [Topic name](https://learn.microsoft.com/...)
```

#### Folders to update

| Folder | Current state | Action |
|--------|---------------|--------|
| `arc-sql-best-practice-assessment` | Partial template | Align to template |
| `arc-sql-connectivity` | Partial template | Align to template |
| `arc-sql-data-collection` | Minimal | Align to template |
| `arc-sql-faq` | Long FAQ format | Keep FAQ format; add metadata + lint |
| `arc-sql-hands-on-lab` | Lab format | Keep lab format; add metadata + lint |
| `arc-sql-modify-license-type` | Partial template | Align to template |
| `arc-sql-monitoring` | Minimal | Align to template |
| `arc-sql-presentation-files` | Minimal | Align to template (short) |
| `arc-sql-report-reclass-extension-status` | Partial template | Align to template |
| `arc-sql-value-proposition` | Multi-file | Add metadata; lint only |
| `arc-sql-videos` | Link list | Add metadata; lint only |

---

### 3. Naming and casing

| Check | Action |
|-------|--------|
| All folder READMEs named `README.md` (uppercase) | Verify; rename if needed |
| Internal links match real file casing | Grep for mismatches; fix |
| Folder names stable | Do not rename unless explicitly required |

---

### 4. Sequencing cues (hands-on lab)

| File | Action |
|------|--------|
| `arc-sql-hands-on-lab/README.md` | Ensure module headings include numbers |
| `arc-sql-hands-on-lab/README.md` | Add "Previous / Next" navigation at module end |
| `arc-sql-hands-on-lab/QUICKSTART.md` | Verify numbered steps |
| `arc-sql-hands-on-lab/LAB-OVERVIEW.md` | Verify numbered steps |

---

### 5. Visual cues (callouts)

Use consistently across all files:

| Callout | When to use | Syntax |
|---------|-------------|--------|
| Note | Tips, additional info | `> [!NOTE]` |
| Important | Billing/licensing consequences | `> [!IMPORTANT]` |
| Warning | Destructive/uninstall actions | `> [!WARNING]` |

Preview features should include:

```markdown
> [!WARNING]
> This feature is in **preview**. Review the [preview terms][preview-terms] before use.
```

---

### 6. Lint/format pass

Run on every markdown file:

| Issue | Detection | Fix |
|-------|-----------|-----|
| Lines > 120 chars | PowerShell/grep scan | Wrap or use reference links |
| Trailing whitespace | `\s+$` regex | Remove |
| Missing blank lines around headings | Manual review | Add blank lines |
| Duplicate headings | `grep` for `^#` | Rename or remove |
| Missing code fence language | `grep` for triple backticks | Add language identifier |
| File does not end with single newline | Check last byte | Add newline |
| `docs.microsoft.com` links | `grep` | Replace with `learn.microsoft.com` |
| "Azure AD" terminology | `grep` | Replace with "Microsoft Entra ID" |

---

## Execution order

| Phase | Tasks | Estimated effort |
|-------|-------|------------------|
| **Phase 1** | Root README rewrite (deliverable 1) | 1 hour |
| **Phase 2** | Folder README template alignment (deliverable 2) | 2–3 hours |
| **Phase 3** | Naming/casing audit (deliverable 3) | 30 min |
| **Phase 4** | Lab sequencing cues (deliverable 4) | 1 hour |
| **Phase 5** | Callout standardization (deliverable 5) | 1 hour |
| **Phase 6** | Repo-wide lint/format pass (deliverable 6) | 2 hours |
| **Phase 7** | Link validation (broken link scan) | 30 min |
| **Phase 8** | Final review + commit | 30 min |

---

## Acceptance checklist

- [ ] A new visitor can pick a task and reach the right doc in two clicks or less
- [ ] Root README reads like a landing page, not an essay
- [ ] All docs use consistent metadata, headings, lists, and code fences
- [ ] Links use `learn.microsoft.com` with `view=sql-server-ver17` where relevant
- [ ] No new content beyond what is required to improve navigation and readability
- [ ] All internal links resolve (no broken links)
- [ ] All lines ≤ 120 characters
- [ ] All files end with a single newline
- [ ] Preview features marked with ⚠️ and link to preview terms
- [ ] Billing/licensing changes have `[!IMPORTANT]` callouts

---

## Notes

- If any requested change is ambiguous, choose the simplest option that improves usability.
- If a file mostly duplicates Microsoft Learn, keep it short and link out.
- Folder `media/` contains images only—no README needed.
