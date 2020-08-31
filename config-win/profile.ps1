$rc = "$env:HOMEPATH/.profile.ps1"

if (Test-Path $rc) {
  . $rc
}