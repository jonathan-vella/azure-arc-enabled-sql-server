#Requires -Version 7.0
<#
.SYNOPSIS
    Validates the markdown documentation in this repository.

.DESCRIPTION
    Runs the same checks locally and in CI:
      - metadata (Version and Last updated after the H1)
      - internal links and heading anchors
      - line length (120, only where the line can be wrapped), code fence languages, trailing whitespace, final newline
      - stale references (deleted files, docs.microsoft.com, /en-us/, "Azure AD", missing view= on SQL Server docs)
      - mechanical unslop patterns (em dashes, en dashes, curly quotes, decorative emojis)
      - hands-on lab module index consistency

    External URLs are not fetched. The link-check workflow does that.

.EXAMPLE
    pwsh .github/scripts/check-docs.ps1
#>
[CmdletBinding()]
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [int]$MaxLineLength = 120
)

$ErrorActionPreference = 'Stop'
$errors = [System.Collections.Generic.List[string]]::new()
function Add-Issue([string]$File, [int]$Line, [string]$Message) {
    $rel = [System.IO.Path]::GetRelativePath($Root, $File).Replace('\', '/')
    $errors.Add(($Line -gt 0) ? "${rel}:${Line}: $Message" : "${rel}: $Message")
}

$files = Get-ChildItem -Path $Root -Recurse -File -Filter *.md |
    Where-Object {
        $_.FullName -notmatch '[\\/](\.git|node_modules)[\\/]' -and
        # Vendored instruction files keep their upstream style.
        $_.Name -notin 'bicep-code-best-practices.instructions.md', 'terraform-azure.instructions.md'
    }

# Parse each file once: raw text, lines, code-fence mask, headings.
$docs = @{}
foreach ($f in $files) {
    $text = [System.IO.File]::ReadAllText($f.FullName)
    $lines = $text -split "\r?\n"
    $inFence = $false
    $mask = [bool[]]::new($lines.Count)
    $headings = [System.Collections.Generic.List[string]]::new()
    $slugCount = @{}
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $l = $lines[$i]
        if ($l -match '^\s*(```|~~~)') {
            $mask[$i] = $true
            $inFence = -not $inFence
            continue
        }
        $mask[$i] = $inFence
        if (-not $inFence -and $l -match '^(#{1,6})\s+(.+?)\s*#*\s*$') {
            $t = $Matches[2]
            $t = [regex]::Replace($t, '\[([^\]]*)\]\([^)]*\)', '$1')
            $t = $t -replace '[`*_~]', '' -replace '<[^>]+>', ''
            $slug = ($t.ToLowerInvariant() -replace '[^\p{L}\p{N}\s\-_]', '') -replace ' ', '-'
            if ($slugCount.ContainsKey($slug)) { $slugCount[$slug]++; $slug = "$slug-$($slugCount[$slug])" }
            else { $slugCount[$slug] = 0 }
            $headings.Add($slug)
        }
    }
    $docs[$f.FullName] = [pscustomobject]@{ Text = $text; Lines = $lines; Mask = $mask; Headings = $headings }
}

$emoji = '[\u2300-\u23FF\u2600-\u27BF\u2B00-\u2BFF]|[\uD83C-\uD83E][\uDC00-\uDFFF]'

foreach ($f in $files) {
    $d = $docs[$f.FullName]
    $rel = [System.IO.Path]::GetRelativePath($Root, $f.FullName).Replace('\', '/')
    $isGithub = $rel.StartsWith('.github/')

    if (-not $d.Text.EndsWith("`n") -or $d.Text.EndsWith("`n`n") -or $d.Text.EndsWith("`r`n`r`n")) {
        Add-Issue $f.FullName 0 'file must end with exactly one newline'
    }

    if (-not $isGithub) {
        $head = ($d.Lines | Select-Object -First 8) -join "`n"
        if ($d.Lines[0] -notmatch '^# ') { Add-Issue $f.FullName 1 'first line must be the H1' }
        if ($head -notmatch '(?m)^Version: v\d+\.\S+ *$') { Add-Issue $f.FullName 0 'missing "Version: v1.YYYY.MM" after H1' }
        if ($head -notmatch '(?m)^Last updated: \d{4}-\d{2}-\d{2} *$') { Add-Issue $f.FullName 0 'missing "Last updated: YYYY-MM-DD" after H1' }
    }

    for ($i = 0; $i -lt $d.Lines.Count; $i++) {
        $line = $d.Lines[$i]
        $n = $i + 1
        $inCode = $d.Mask[$i]

        if ($line -match '^\s*(```|~~~)\s*$' -and -not ($i -gt 0 -and $d.Mask[$i - 1] -and $d.Mask[$i])) {
            # A bare fence is only valid as a closing fence: the previous line must be inside a fence.
            if (-not ($i -gt 0 -and $d.Mask[$i - 1])) { Add-Issue $f.FullName $n 'code fence without a language' }
        }

        if ($line -match '\s+$' -and $line -notmatch '^Version: v' -and $line -ne '') {
            Add-Issue $f.FullName $n 'trailing whitespace'
        }

        if (-not $inCode -and $line.Length -gt $MaxLineLength -and $line -notmatch '^\s*\|' -and
            $line.Substring($MaxLineLength) -match '\s') {
            Add-Issue $f.FullName $n "line is $($line.Length) characters (max $MaxLineLength)"
        }

        if ($inCode) { continue }
        $prose = [regex]::Replace($line, '`[^`]*`', '')
        $prose = $prose.Replace("$([char]0x26A0)$([char]0xFE0F)", '').Replace([string][char]0x26A0, '')
        if ($prose -match '[\u2014\u2013]') { Add-Issue $f.FullName $n 'em or en dash (unslop 13)' }
        if ($prose -match '[\u2018\u2019\u201C\u201D]') { Add-Issue $f.FullName $n 'curly quote (unslop 19)' }
        if ($prose -match $emoji) { Add-Issue $f.FullName $n 'decorative emoji (unslop 18)' }
        if ($line -match '^#{2,6}\s') {
            $words = ($line -replace '^#+\s+', '' -replace '[`*]', '') -split '\s+'
            $caps = $words | Select-Object -Skip 1 | Where-Object { $_ -cmatch '^[A-Z][a-z]{3,}$' }
            if (@($caps).Count -ge 2) { Add-Issue $f.FullName $n 'heading looks like Title Case (unslop 17)' }
        }

        if (-not $isGithub) {
            if ($line -match 'docs\.microsoft\.com') { Add-Issue $f.FullName $n 'docs.microsoft.com link' }
            if ($line -match 'learn\.microsoft\.com/en-us/') { Add-Issue $f.FullName $n 'remove /en-us/ from learn.microsoft.com link' }
            if ($line -match '\b(Azure AD|AzureAD|AAD)\b') { Add-Issue $f.FullName $n 'use "Microsoft Entra ID"' }
            if ($line -match 'learn\.microsoft\.com/sql/sql-server/azure-arc[^)\s>]*' -and $Matches[0] -notmatch 'view=sql-server-ver17') {
                Add-Issue $f.FullName $n 'SQL Server Arc docs link is missing ?view=sql-server-ver17'
            }
            if ($line -match 'LAB-OVERVIEW|lab-commands|arc-server-onboarding-automation|arc-sql-install-payg|microsoft/azure-arc-enabled-sql-server') {
                Add-Issue $f.FullName $n "stale reference: $($Matches[0])"
            }
        }
    }

    # Internal links and anchors.
    $targets = [System.Collections.Generic.List[object]]::new()
    for ($i = 0; $i -lt $d.Lines.Count; $i++) {
        if ($d.Mask[$i]) { continue }
        $line = [regex]::Replace($d.Lines[$i], '`[^`]*`', '')
        foreach ($m in [regex]::Matches($line, '!?\[[^\]]*\]\(<?([^)\s>]+)>?(?:\s+"[^"]*")?\)')) { $targets.Add(@(($i + 1), $m.Groups[1].Value)) }
        if ($line -match '^\s*\[[^\]]+\]:\s*<?(\S+?)>?\s*$') { $targets.Add(@(($i + 1), $Matches[1])) }
        foreach ($m in [regex]::Matches($line, 'href="([^"]+)"')) { $targets.Add(@(($i + 1), $m.Groups[1].Value)) }
    }
    foreach ($t in $targets) {
        $n = $t[0]; $url = $t[1]
        if ($url -match '^[a-zA-Z][a-zA-Z0-9+.-]*:' -or $url.StartsWith('//')) { continue }
        $pathPart, $frag = $url -split '#', 2
        $pathPart = [uri]::UnescapeDataString(($pathPart -split '\?')[0])
        $target = if ($pathPart -eq '') { $f.FullName }
                  elseif ($pathPart.StartsWith('/')) { Join-Path $Root $pathPart.TrimStart('/') }
                  else { Join-Path $f.DirectoryName $pathPart }
        if (-not (Test-Path -LiteralPath $target)) { Add-Issue $f.FullName $n "broken link: $url"; continue }
        if ($frag -and $target -like '*.md') {
            $full = (Resolve-Path -LiteralPath $target).Path
            if ($docs.ContainsKey($full) -and $docs[$full].Headings -notcontains $frag.ToLowerInvariant()) {
                Add-Issue $f.FullName $n "broken anchor: $url"
            }
        }
    }
}

# Hands-on lab module index.
$labDir = Join-Path $Root 'arc-sql-hands-on-lab'
$modDir = Join-Path $labDir 'modules'
if (Test-Path $modDir) {
    $labReadme = Join-Path $labDir 'README.md'
    $indexText = $docs[$labReadme].Text
    $seen = @{}
    foreach ($m in Get-ChildItem $modDir -Filter *.md) {
        if ($m.Name -notmatch '^(\d{2})-[a-z0-9-]+\.md$') { Add-Issue $m.FullName 0 'module file must be named NN-kebab-case.md'; continue }
        $num = $Matches[1]
        if ($seen.ContainsKey($num)) { Add-Issue $m.FullName 0 "duplicate module number $num" }
        $seen[$num] = $true
        $d = $docs[$m.FullName]
        if ($d.Lines[0] -notmatch "^# Module $([int]$num):") { Add-Issue $m.FullName 1 "H1 must start with 'Module $([int]$num):'" }
        if ($d.Text -notmatch '\]\(\.\./README\.md') { Add-Issue $m.FullName 0 'missing link back to the module index' }
        if ($indexText -notmatch [regex]::Escape("modules/$($m.Name)")) { Add-Issue $labReadme 0 "module index does not link to modules/$($m.Name)" }
    }
}

if ($errors.Count) {
    $errors | ForEach-Object { Write-Host $_ }
    Write-Host "`n$($errors.Count) documentation issue(s) in $($files.Count) files." -ForegroundColor Red
    exit 1
}
Write-Host "Documentation checks passed for $($files.Count) files." -ForegroundColor Green
