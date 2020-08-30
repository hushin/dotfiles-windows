try { $null = gcm pshazz -ea stop; pshazz init } catch { }

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox

function Prompt {
  $e = $?
  $ErrorActionPreference = "Stop"
  Write-Host "# " -ForegroundColor Blue -NoNewLine
  Write-Host $env:USERNAME -ForegroundColor Cyan -NoNewLine
  Write-Host " @ " -ForegroundColor White -NoNewLine
  Write-Host $env:COMPUTERNAME -ForegroundColor Green -NoNewLine
  Write-Host " in " -ForegroundColor White -NoNewLine
  Write-Host ((Get-Location).Path.replace($HOME, "~")) -ForegroundColor Yellow -NoNewLine
  $isGit = Test-Path -Path ((Get-Location).Path + "\.git")
  if ($isGit) {
    Write-Host " on git:" -ForegroundColor White -NoNewline
    $result = git status
    Write-Host (Write-Output $result | Select-String "On branch" | ForEach-Object { $_ -replace ("On branch ", "") }) -ForegroundColor cyan -NoNewline
    if ($result[-1].Contains("working tree clean")) {
      Write-Host " o"  -ForegroundColor Green -NoNewline
    }
    else {
      Write-Host " x"  -ForegroundColor Red -NoNewline
    }
  }
  Write-Host (Get-Date -UFormat " [%T]") -ForegroundColor White -NoNewLine
  if (!($e)) {
    Write-Host " E" -ForegroundColor Red -NoNewLine
  }
  Write-Host "`nPS" -ForegroundColor DarkCyan -NoNewline
  "> "
}

function Invoke-GhqFzf {
  $selected_dir = git config --get ghq.root
  if ($selected_dir) {
    $target = ghq list | fzf
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Set-Location $selected_dir\$target")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
  }
  else {
    Write-Output "Cannot find ghq.root"
  }
}

Set-PSReadLineKeyHandler -Chord Ctrl+z -ScriptBlock {
  Invoke-GhqFzf
}

function Invoke-HistoryFzf {
  $cmd = Get-Content (Get-PSReadLineOption).HistorySavePath | fzf
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert($cmd)
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
  Invoke-HistoryFzf
}

# for Windows 7/8
if ([System.Environment]::OSVersion.Version.Major -le 6) {
  if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
  }
  else {
    # https://github.com/psget/psget/issues/237
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    (new-object Net.WebClient).DownloadString("http://bit.ly/GetPsGet") | Invoke-Expression
  }
}

Set-PSReadLineKeyHandler -Chord Ctrl+d -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('exit')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord Ctrl+a BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+e EndOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+w BackwardKillWord
Set-PSReadLineKeyHandler -Chord Alt+f NextWord
Set-PSReadLineKeyHandler -Chord Alt+b BackwardWord

Remove-Item Alias:cd -ErrorAction Ignore

function cd {
  if ($args.Length -gt 0) {
    Set-Location $args[0]
  }
  else {
    Set-Location $env:HOMEPATH
  }
}

# $env:FZF_DEFAULT_COMMAND = '--files --hidden --glob "!.git"'
$env:FZF_DEFAULT_OPTS = '--reverse --border'

$localrc = "$env:HOMEPATH/.profile.local.ps1"

if (Test-Path $localrc) {
  . $localrc
}