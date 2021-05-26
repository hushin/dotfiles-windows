try { $null = gcm pshazz -ea stop; pshazz init } catch { }

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# https://2ndlife.secon.dev/entry/2020/08/17/070735
Import-Module posh-git
Import-Module oh-my-posh
Import-Module ZLocation
Set-PoshPrompt -Theme agnoster

$env:GIT_SSH = "C:\WINDOWS\System32\OpenSSH\ssh.exe"
$env:FZF_DEFAULT_COMMAND = 'rg -g "" --hidden --ignore ".git"'
# $env:FZF_DEFAULT_OPTS = '--reverse --border'

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
# 標準だと Ctrl+d は DeleteCharOrExit のため、うっかり端末が終了することを防ぐ
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
# EditMode Emacs 標準のタブ補完
Set-PSReadLineKeyHandler -Key Tab -Function Complete
# メニュー補完に変更
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete


# uutils-coreutils プロファイルに追加
@"
  arch, base32, base64, basename, cat, cksum, comm, cp, cut, date, df, dircolors, dirname,
  echo, env, expand, expr, factor, false, fmt, fold, hashsum, head, hostname, join, link, ln,
  ls, md5sum, mkdir, mktemp, more, mv, nl, nproc, od, paste, printenv, printf, ptx, pwd,
  readlink, realpath, relpath, rm, rmdir, seq, sha1sum, sha224sum, sha256sum, sha3-224sum,
  sha3-256sum, sha3-384sum, sha3-512sum, sha384sum, sha3sum, sha512sum, shake128sum,
  shake256sum, shred, shuf, sleep, sort, split, sum, sync, tac, tail, tee, test, touch, tr,
  true, truncate, tsort, unexpand, uniq, wc, whoami, yes
"@ -split ',' |
ForEach-Object { $_.trim() } |
Where-Object { ! @('tee', 'sort', 'sleep').Contains($_) } |
ForEach-Object {
    $cmd = $_
    if (Test-Path Alias:$cmd) { Remove-Item -Path Alias:$cmd }
    $fn = '$input | uutils ' + $cmd + ' $args'
    Invoke-Expression "function global:$cmd { $fn }"
}

Set-Alias grep rg

function cd {
  if ($args.Length -gt 0) {
    Set-Location $args[0]
  }
  else {
    Set-Location $env:HOMEPATH
  }
}

function gf {
  $path = ghq list | fzf
  if ($LastExitCode -eq 0) {
    cd "$(ghq root)\$path"
  }
}
function ghg {
  ghq get --shallow $args
}

function mkdev {
  if ($args.Length -ne 1) {
		echo "Usage: mkdev dir-name"
    return
  }
  $dirName = $args[0]
  $devPath = "$(ghq root)\github.com\$(git config user.name)\$dirName"
  mkdir -p $devPath
  cd $devPath
  git init
}

function mksandbox {
  if ($args.Length -ne 1) {
		echo "Usage: mksandbox dir-name"
    return
  }
  $dirName = $args[0]
  $devPath = "$(ghq root)\github.com\$(git config user.name)-sandbox\$dirName"
  mkdir -p $devPath
  cd $devPath
  git init
}

function crrepo {
  # TODO cd-gitroot したい
  $pwd = $(pwd)
  $dirName = $pwd -replace '\\', '/'
  $dirName -match '[^/]*?/[^/]*?$' > $null
  $repoName = $Matches[0]
  hub create $args $repoName
}

# key binding
# 実行後入力待ちになるため、AcceptLine を実行する
Set-PSReadLineKeyHandler -Chord 'Ctrl+]' -ScriptBlock { gf; [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() }
Set-PSReadLineKeyHandler -Chord 'Ctrl+j' -ScriptBlock  { Invoke-FuzzyZLocation; [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() }
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

$localrc = "$env:HOMEPATH/.profile.local.ps1"

if (Test-Path $localrc) {
  . $localrc
}
