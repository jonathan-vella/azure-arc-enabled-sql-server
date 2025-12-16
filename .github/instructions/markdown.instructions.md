---
description: "Documentation and content creation standards for markdown files"
applyTo: "**/*.md"
---

# Markdown Documentation Standards

Standards for creating consistent, accessible, and well-structured markdown documentation.
Follow these guidelines to ensure documentation quality across the repository.

## Document Metadata Requirements

Every markdown documentation file **must** include the following metadata immediately after the H1 title:

```markdown
# Document Title

Version: v1.2025.12
Last updated: 2025-12-16

Brief description...
```

### Metadata Fields

| Field | Format | Description | Automation |
|-------|--------|-------------|------------|
| **Version** | `v1.YYYY.MM` | Semantic version based on year/month | Auto-updated by GitHub Action |
| **Last updated** | `YYYY-MM-DD` | ISO 8601 date of last modification | Auto-updated by GitHub Action |

**Note:** These fields are automatically maintained by the `update-doc-metadata.yml` workflow on merge to `main`.
For new documents, add these fields manually with the current date; they will be updated automatically on subsequent changes.

### Front Matter Policy

- **Required only for:** `.github/instructions/*.md` files (Copilot instruction files)
- **Not required for:** All other documentation files
- If present in non-instruction files, it should be removed to maintain consistency

## Filename Conventions

- Use `README.md` (uppercase) for directory index files
- Use kebab-case for other markdown files: `my-document-name.md`
- Never use spaces in filenames

## General Instructions

- Use ATX-style headings (`##`, `###`) - never use H1 (`#`) in content (reserved for document title)
- **CRITICAL: Limit line length to 120 characters** - this is enforced by CI/CD and pre-commit hooks
- Break long lines at natural points (after punctuation, before conjunctions)
- Use LF line endings (enforced by `.gitattributes`)
- Include meaningful alt text for all images
- Validate with `markdownlint` before committing

## Line Length Guidelines

The 120-character limit is strictly enforced. When lines exceed this limit:

1. **Sentences**: Break after punctuation (period, comma, em-dash)
2. **Lists**: Break after the list marker or continue on next line with indentation
3. **Links**: Break before `[` or use reference-style links for long URLs
4. **Code spans**: If unavoidable, use a code block instead

**Example - Breaking long lines:**

```markdown
<!-- BAD: 130+ characters -->

This is a very long line that contains important information about Azure resources and best practices that exceeds the limit.

<!-- GOOD: Natural break after punctuation -->

This is a very long line that contains important information about Azure resources
and best practices that stays within the limit.
```

## Content Structure

| Element     | Rule                                     | Example                                                    |
| ----------- | ---------------------------------------- | ---------------------------------------------------------- |
| Headings    | Use `##` for H2, `###` for H3, avoid H4+ | `## Section Title`                                         |
| Lists       | Use `-` for unordered, `1.` for ordered  | `- Item one`                                               |
| Code blocks | Use fenced blocks with language          | ` ```bicep `                                               |
| Links       | Descriptive text, valid URLs             | `[Azure docs](https://...)`                                |
| Images      | Include alt text                         | `![Architecture diagram](https://example.com/diagram.png)` |
| Tables      | Align columns, include headers           | See examples below                                         |

## Code Blocks

Specify the language after opening backticks for syntax highlighting:

### Good Example - Language-specified code block

````markdown
```bicep
param location string = 'swedencentral'
```
````

### Bad Example - No language specified

````markdown
```
param location string = 'swedencentral'
```
````

## Mermaid Diagrams

Always include the theme directive for dark mode compatibility:

### Good Example - Mermaid with theme directive

```markdown
​`mermaid
%%{init: {'theme':'neutral'}}%%
graph LR
    A[Start] --> B[End]
​`
```

### Bad Example - Missing theme directive

```markdown
​`mermaid
graph LR
    A[Start] --> B[End]
​`
```

## Lists and Formatting

- Use `-` for bullet points (not `*` or `+`)
- Use `1.` for numbered lists (auto-increment)
- Indent nested lists with 2 spaces
- Add blank lines before and after lists

### Good Example - Proper list formatting

```markdown
Prerequisites:

- Azure CLI 2.50+
- Bicep CLI 0.20+
- PowerShell 7+

Steps:

1. Clone the repository
2. Run the setup script
3. Verify installation
```

### Bad Example - Inconsistent list markers

```markdown
Prerequisites:

- Azure CLI 2.50+

* Bicep CLI 0.20+

- PowerShell 7+
```

## Tables

- Include header row with alignment
- Keep columns aligned for readability
- Use tables for structured comparisons

```markdown
| Resource  | Purpose            | Example          |
| --------- | ------------------ | ---------------- |
| Key Vault | Secrets management | `kv-contoso-dev` |
| Storage   | Blob storage       | `stcontosodev`   |
```

## Links and References

- Use descriptive link text (not "click here")
- Verify all links are valid and accessible
- Prefer relative paths for internal links

### Good Example - Descriptive links

```markdown
See the [getting started guide](../../docs/guides/quickstart.md) for setup instructions.
Refer to [Azure Bicep documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/) for syntax details.
```

### Bad Example - Non-descriptive links

```markdown
Click [here](../../docs/guides/quickstart.md) for more info.
```

## Front Matter (Optional)

For blog posts or published content, include YAML front matter:

```yaml
---
post_title: "Article Title"
author1: "Author Name"
post_slug: "url-friendly-slug"
post_date: "2025-01-15"
summary: "Brief description of the content"
categories: ["Azure", "Infrastructure"]
tags: ["bicep", "iac", "azure"]
---
```

**Note**: Front matter fields are project-specific. General documentation files may not require all fields.

## Patterns to Avoid

| Anti-Pattern            | Problem                      | Solution                   |
| ----------------------- | ---------------------------- | -------------------------- |
| H1 in content           | Conflicts with title         | Use H2 (`##`) as top level |
| Deep nesting (H4+)      | Hard to navigate             | Restructure content        |
| Long lines (>120 chars) | Poor readability, lint fails | Break at natural clauses   |
| Missing code language   | No syntax highlighting       | Specify language           |
| "Click here" links      | Poor accessibility           | Use descriptive text       |
| Excessive whitespace    | Inconsistent appearance      | Single blank lines         |

## Validation

Run these commands before committing markdown:

```bash
# Lint all markdown files
markdownlint '**/*.md' --ignore node_modules --config .markdownlint.json

# Check for broken links (if using markdown-link-check)
markdown-link-check README.md

# Check all internal and external links
find . -name "*.md" -exec markdown-link-check {} \;
```

### Automated Link Validation

The repository includes automated link checking:

- **On Pull Request:** Links in changed `.md` files are validated
- **Manual trigger:** Full repository link scan via `ms-learn-link-check.yml`
- **Issue creation:** Broken links automatically create GitHub issues for tracking

### Link Types Validated

| Link Type | Example | Validation |
|-----------|---------|------------|
| Microsoft Learn | `https://learn.microsoft.com/...` | HTTP status check |
| Internal relative | `../folder/file.md` | File existence check |
| Image paths | `media/image.png` | File existence check |
| External URLs | `https://github.com/...` | HTTP status check |

## Table of Contents Requirement

Documents exceeding **150 lines** must include a Table of Contents after the metadata section:

```markdown
# Document Title

Version: v1.2025.12
Last updated: 2025-12-16

Brief description of the document.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Related Resources](#related-resources)

---

## Overview
...
```

## Standard Document Template

Use this template structure for new documentation:

```markdown
# Document Title

Version: v1.2025.12
Last updated: 2025-12-16

Brief one-paragraph description of what this document covers.

## Table of Contents

(Required for documents >150 lines)

---

## Overview

Detailed description of the topic, feature, or script.

## Prerequisites

- Requirement 1
- Requirement 2

## Getting Started / Installation / Usage

Step-by-step instructions...

## Examples

### Example 1: Basic Usage

```powershell
# Example code with language specified
```

## Troubleshooting

Common issues and solutions...

## Related Resources

- [Related Doc 1](https://learn.microsoft.com/...)
- [Internal Doc](../folder/README.md)
```

## Maintenance

- Review documentation when code changes
- Update examples to reflect current patterns
- Remove references to deprecated features
- Verify all links remain valid
- Version and date are auto-updated on merge to main
