fsutil 8dot3name set 1
$DOTFILES = "$env:USERPROFILE\.dotfiles"
$PSUSERHOME = $profile -replace "^(.*)\\.*$", "`$1" -replace "^(.*)\\.*$", "`$1"

Add-MpPreference -ExclusionPath $env:USERPROFILE\.cache
Add-MpPreference -ExclusionPath $env:USERPROFILE\.config
Add-MpPreference -ExclusionPath $env:USERPROFILE\.dotfiles
Add-MpPreference -ExclusionPath $env:USERPROFILE\bin
Add-MpPreference -ExclusionPath $env:USERPROFILE\scoop
Add-MpPreference -ExclusionPath $env:USERPROFILE\ghq
Add-MpPreference -ExclusionPath $env:USERPROFILE\pkg
Add-MpPreference -ExclusionPath "$env:USERPROFILE\Hyper-V"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\VirtualBox VMs"
Add-MpPreference -ExclusionPath $env:LOCALAPPDATA\Packages\CanonicalGroupLimited.Ubuntu20.04onWindows_79rhkp1fndgsc\LocalState
Add-MpPreference -ExclusionPath $env:ProgramData\scoop
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1

# 拡張子を表示
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f

switch ((Get-WmiObject -Class Win32_ComputerSystem).Model) {
  "Virtual Machine" {
    $isVM = $true
  }
  "VMware Virtual Platform" {
    $isVM = $true
  }
  "VirtualBox" {
    $isVM = $true
  }
  default {
    $isVM = $false
  }
}

$enableFeatures = @(
  "TelnetClient"
)
$disableFeatures = @(
  "WorkFolders-Client"
)
if (! $isVM) {
  $virtualizationFeatures = @(
    "Containers"
    "Microsoft-Hyper-V"
    "Microsoft-Windows-Subsystem-Linux"
    "HypervisorPlatform"
    "VirtualMachinePlatform"
  )
  $enableFeatures += $virtualizationFeatures
}

foreach ($enableFeature in $enableFeatures) {
  if ((Get-WindowsOptionalFeature -Online -FeatureName $enableFeature).State -eq "Disabled") {
    Write-Output "Try to enable $enableFeature"
    Enable-WindowsOptionalFeature -Online -All -NoRestart -FeatureName $enableFeature
  }
  else {
    Write-Output "$enableFeature has been already enabled"
  }
}

foreach ($disableFeature in $disableFeatures) {
  if ((Get-WindowsOptionalFeature -Online -FeatureName $disableFeature).State -eq "Enabled") {
    Write-Output "Try to disable $disableFeature"
    Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $disableFeature
  }
  else {
    Write-Output "$disableFeature has been already disabled"
  }
}

# profile
New-Item -Force -ItemType SymbolicLink -Path $env:USERPROFILE\.profile.ps1 -Value $DOTFILES\.profile.ps1

## Windows Powershell
New-Item -Force -ItemType SymbolicLink -Path $PSUSERHOME\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -Value $DOTFILES\profile.ps1
## Powershell Core
New-Item -Force -ItemType SymbolicLink -Path $PSUSERHOME\PowerShell\Microsoft.PowerShell_profile.ps1 -Value $DOTFILES\profile.ps1

## VSCode
New-Item -Force -ItemType SymbolicLink -Path $PSUSERHOME\WindowsPowerShell\Microsoft.VSCode_profile.ps1 -Value $DOTFILES\profile.ps1

# dotfiles
New-Item -Force -ItemType SymbolicLink -Path $env:USERPROFILE\.editorconfig -Value $DOTFILES\config\.editorconfig
New-Item -Force -ItemType SymbolicLink -Path $env:USERPROFILE\.gitconfig -Value $DOTFILES\config\.gitconfig
New-Item -Force -ItemType SymbolicLink -Path $env:USERPROFILE\.gitignore -Value $DOTFILES\config\.gitignore
New-Item -Force -ItemType SymbolicLink -Path $env:USERPROFILE\.tigrc -Value $DOTFILES\config\.tigrc
New-Item -Force -ItemType SymbolicLink -Path $env:USERPROFILE\.prettierrc -Value $DOTFILES\config\.prettierrc
New-Item -Force -ItemType SymbolicLink -Path $env:USERPROFILE\.npmrc -Value $DOTFILES\config\.npmrc

# Windows Terminal
New-Item -Force -ItemType SymbolicLink -Path $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json -Value $DOTFILES\config-win\WindowsTerminal\LocalState\settings.json
New-Item -Force -ItemType SymbolicLink -Path $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json -Value $DOTFILES\config-win\WindowsTerminal\LocalState\settings.json

# keyhac
New-Item -Force -ItemType SymbolicLink -Path $PSUSERHOME\bin\keyhac\config.py -Value $DOTFILES\config-win\keyhac\config.py
# AutoHotKey
New-Item -Force -ItemType SymbolicLink -Path $PSUSERHOME\SetUp\AutoHotKey\MacLikeKeybind.ahk -Value $DOTFILES\config-win\ahk\MacLikeKeybind.ahk

# memo
New-Item -Force -ItemType SymbolicLink -Path $env:APPDATA\memo\config.toml -Value $DOTFILES\config-win\memo\config.toml

Start-Sleep -Seconds 5