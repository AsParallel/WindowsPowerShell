# Hack around corporate IT
if ($home -eq "M:\") {
  Set-Variable -Name HOME -Value "$env:systemdrive\users\$env:username" -Force
  Set-Variable -Name HOMEDRIVE -Value "$env:systemdrive" -Force
  Set-Variable -Name HOMEPATH -Value "\users\$env:username" -Force
  (Get-PSProvider filesystem).home = $home
}

# Modules
if ($host.Version.Major -lt 5) { Import-Module PsGet }
Import-Module PSReadLine
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
