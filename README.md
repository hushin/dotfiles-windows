# dotfiles-windows

## Installation

```powershell
Set-ExecutionPolicy -Scope Process Unrestricted
iex(new-object net.webclient).downloadstring('https://raw.githubusercontent.com/hushin/dotfiles-windows/master/make.ps1')
```

## Initialize

```
code $env:USERPROFILE\.gitconfig.local
```

```
[user]
  name = hushin
  email = nnnnot+github@gmail.com
```
