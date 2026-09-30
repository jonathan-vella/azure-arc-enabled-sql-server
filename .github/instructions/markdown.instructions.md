---
description: "Documentation and content creation standards for markdown files"
applyTo: "**/*.md"
---

# Markdown documentation standards

Rules for every markdown file in this repository. For prose style, follow the
[unslop skill](../skills/unslop/SKILL.md) and do not restate its rules here.
`.github/scripts/check-docs.ps1` enforces the mechanical rules locally and in CI.

## Metadata

Every `.md` file outside `.github/` starts with the H1, then two metadata lines:

```markdown
# Document title

Version: v1.2026.09
Last updated: 2026-09-30
```

| Field | Format | Maintained by |
| --- | --- | --- |
| Version | `v1.YYYY.MM` | `update-doc-metadata.yml` on merge to `main` |
| Last updated | `YYYY-MM-DD` | `update-doc-metadata.yml` on merge to `main` |

Set both by hand in new files. Vendored upstream READMEs keep their own version string (`v3.0.5`) in the same place.
Files under `.github/` are exempt. Copilot instruction files use YAML front matter instead.

## Structure

- Use one H1 (the title). Use `##` and `###`. Avoid H4 and deeper.
- Write headings in sentence case and keep them free of durations or dates, so anchors stay stable.
- Put the task first. A reader should reach the command or the answer in the first screen.
- Add a table of contents to documents over 150 lines. Hands-on lab module files are exempt; the lab README is the index.
- Use `-` for bullets, `1.` for numbered lists, and two spaces to indent nested lists.
- Name files `README.md` for folder indexes and kebab-case otherwise. Use no spaces.

## Formatting

- Wrap lines at 120 characters. Tables, code blocks, and unbreakable URLs are exempt.
- Use LF line endings and end each file with a single newline.
- Give every code fence a language (`powershell`, `bicep`, `bash`, `text`).
- Add alt text to every image.
- Put `%%{init: {'theme':'neutral'}}%%` first in every Mermaid diagram.

## Callouts and preview marking

- Use GitHub callouts: `> [!NOTE]`, `> [!IMPORTANT]`, `> [!WARNING]`.
- Put licensing or billing changes (PAYG, Software Assurance, ESU) in an `> [!IMPORTANT]` callout.
- Mark preview features with ⚠️ in the heading or first sentence, and link the
  [supplemental terms of use](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).
  This is the only emoji allowed.

## Links

- Use descriptive link text, never "click here".
- Use relative paths for internal links. Point anchors at headings that exist.
- Write Microsoft Learn links without a locale: `https://learn.microsoft.com/azure/...`, not `/en-us/`.
- Add `?view=sql-server-ver17` to SQL Server documentation links under `learn.microsoft.com/sql/`.
  Do not add it to Azure documentation links.
- Use reference-style links when an inline URL would push a line past 120 characters.

## Terminology

- Microsoft Entra ID, not Azure AD.
- SQL Server enabled by Azure Arc is the product name. "Azure Arc-enabled SQL Server" is acceptable in titles.
- Extension names: `WindowsAgent.SqlServer` and `LinuxAgent.SqlServer`.

## Validate before committing

```powershell
pwsh .github/scripts/check-docs.ps1
```

The script checks metadata, internal links and anchors, line length, code fence languages, stale references,
and the mechanical unslop patterns. The link-check workflow validates external URLs on pull requests.