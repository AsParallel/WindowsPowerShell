# Modules
Import-Module PathUtils
Import-Module VisualStudio

if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadline -ErrorAction SilentlyContinue
}

# Paths
Add-Path "$psscriptroot\scripts"

# Aliases
Set-Alias which Get-Command

# Print out a fancy PowerShell Banner :)
if (which figlet -ErrorAction Ignore) {
    Write-Host (figlet -f slant "PowerShell $($Host.Version.ToString(2))" | Out-String) -ForegroundColor Cyan
}

if (gcm pshazz -ea SilentlyContinue) {
    pshazz init 'xpando' 
}
