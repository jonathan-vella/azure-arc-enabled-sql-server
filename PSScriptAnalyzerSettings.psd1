# PSScriptAnalyzer settings for this repository.
# Usage: Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
@{
    Severity     = @('Error', 'Warning')
    # The lab scripts are interactive and use colored console output on purpose.
    ExcludeRules = @('PSAvoidUsingWriteHost')
}
