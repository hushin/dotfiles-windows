# DO NOT RUN ON ISE
# Set-ExecutionPolicy -Scope Process Unrestricted

$DOTFILES = "$env:USERPROFILE\.dotfiles"

# Chocolatey
try {
  Get-Command -Name choco -ErrorAction Stop
}
catch [System.Management.Automation.CommandNotFoundException] {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$CHOCO_PACKAGES = @(
  "dropbox"
  "googlechrome"
  "vscode"
  "1password"
  "vagrant"
  "virtualbox"
  "discord"
  "line"
  "windirstat"
  "autohotkey"
  "adobereader"
  "rapidee"
  "vlc"
  "licecap"
  "synologydrive"
  # "qttabbar"
  "cica"
  "cascadiacodepl"
  "steam"
)

choco update
choco install -y $CHOCO_PACKAGES

# Scoop
try {
  Get-Command -Name scoop -ErrorAction Stop
}
catch [System.Management.Automation.CommandNotFoundException] {
  Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

$SCOOP_PACKAGES = @(
  "7zip"
  "bat"
  "concfg"
  "everything"
  "fzf"
  "ghq"
  "git"
  "go"
  "jq"
  "mpc-be"
  "nodejs-lts"
  "openssh"
  "paint.net"
  "powertoys"
  "ripgrep"
  "ruby"
  "sysinternals"
)

scoop install git
scoop update
scoop bucket add extras
scoop bucket add versions
scoop update *
scoop install $SCOOP_PACKAGES
scoop cache rm *

# https://github.com/lukesampson/scoop/wiki/Theming-Powershell
# back-up current console settings
concfg export console-backup.json
concfg import solarized-dark
scoop install pshazz

if (Test-Path ("$DOTFILES")) {
  Set-Location $DOTFILES
  git pull
}
else {
  git config --global core.autoCRLF false
  git clone https://github.com/hushin/dotfiles-windows $env:USERPROFILE\.dotfiles
}

# profile
$PSUSERHOME = $profile -replace "^(.*)\\.*$", "`$1" -replace "^(.*)\\.*$", "`$1"
## Windows Powershell
New-Item $PSUSERHOME\WindowsPowerShell -Force -ItemType Directory
## Powershell Core
New-Item $PSUSERHOME\PowerShell -Force -ItemType Directory

# Windows Terminal
New-Item -Path $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState -Force -ItemType Directory

# memo
New-Item -Path $env:APPDATA\memo -Force -ItemType Directory

# runas
Start-Process powershell.exe ("-NoProfile -Command cd " + $env:USERPROFILE + "\.dotfiles; .\runas.ps1") -Verb runas

# ruby
$GEMPACKAGES = @(
  "git-browse-remote"
)
gem install $GEMPACKAGES

# nodejs
$NPMPACKAGES = @(
  "npm-check-updates"
  "http-server"
  "npm"
  "init-package-json-parcel"
  "prettier"
)
npm install -g $NPMPACKAGES

# golang
$GOPACKAGES = @(
  "github.com/mattn/memo"
)
Set-Location $env:USERPROFILE
foreach ($GOPACKAGE in $GOPACKAGES) {
  go get -u $GOPACKAGE
}

# gitconfig for windows
if (!(Test-Path -Path $env:USERPROFILE\.gitconfig.local)) {
  New-Item -Path $env:USERPROFILE\.gitconfig.local
}

# deprecated
$deprecated_files = @(
  "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json"
)
foreach ($deprecated_file in $deprecated_files) {
  if (Test-Path -PathType Leaf $deprecated_file) {
    Remove-Item -Force $deprecated_file
  }
}
$deprecated_dirs = @(
  "$env:APPDATA\Hyper"
)
foreach ($deprecated_dir in $deprecated_dirs) {
  if (Test-Path -PathType Container $deprecated_dir) {
    Remove-Item -Force -Recurse $deprecated_dir
  }
}