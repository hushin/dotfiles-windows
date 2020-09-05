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
  "fd"
  "fzf"
  "gawk"
  "ghq"
  "git"
  "go"
  "gzip"
  "jq"
  "less"
  "mpc-be"
  "nodejs-lts"
  "openssh"
  "paint.net"
  "powertoys"
  "pshazz"
  "pwsh"
  "ripgrep"
  "ruby"
  "sed"
  "sudo"
  "sysinternals"
  "tar"
  "uutils-coreutils"
)

scoop install git
scoop update
scoop bucket add extras
scoop bucket add versions
scoop update *
scoop install $SCOOP_PACKAGES
scoop cache rm *

# https://github.com/lukesampson/scoop/wiki/Theming-Powershell
concfg import dracula

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

# keyhac
New-Item $PSUSERHOME\bin\keyhac -Force -ItemType Directory
# AutoHotKey
New-Item $PSUSERHOME\SetUp\AutoHotKey -Force -ItemType Directory

# keyhac Shortcut
$WsShell = New-Object -ComObject WScript.Shell
$Shortcut = $WsShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\keyhac.lnk")
$Shortcut.TargetPath = "$PSUSERHOME\bin\keyhac\keyhac.exe"
$Shortcut.IconLocation = "$PSUSERHOME\bin\keyhac\keyhac.exe"
$Shortcut.WindowStyle = 7 #最小化
$Shortcut.Save()

# memo
New-Item -Path $env:APPDATA\memo -Force -ItemType Directory

# ssh
New-Item -Path $env:USERPROFILE\.ssh -Force -ItemType Directory

# runas
Start-Process powershell.exe ("-NoProfile -Command cd " + $env:USERPROFILE + "\.dotfiles; .\runas.ps1") -Verb runas

# PowerShell
echo "Install posh-git"
Install-Module posh-git -Scope CurrentUser
echo "Install oh-my-posh"
Install-Module oh-my-posh -Scope CurrentUser
echo "Install ZLocation"
Install-Module ZLocation -Scope CurrentUser
echo "Install PSFzf"
Install-Module PSFzf -Scope CurrentUser

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
foreach ($NPMPACKAGE in $NPMPACKAGES) {
  npm install -g $NPMPACKAGE
}

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
