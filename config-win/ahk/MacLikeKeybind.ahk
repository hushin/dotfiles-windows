#SingleInstance force
#InstallKeybdHook
#UseHook
DetectHiddenWindows, on
SetWinDelay, 0
SendMode Input

;Shift  +
;Ctrl   ^
;Alt    !
;Win    #

F13 & Tab::AltTab
!Tab::Send, #{Tab}

; LWin+Click -> Ctrl+Click
~F13 & LButton::
  Send, {Control down}
  MouseClick, left, %A_CaretX%, %A_CaretY%
  Send, {Control up}
  Return

; sound volume
RShift & F12::
  SoundSet, +1
  SoundPlay,*64
  return

RShift & F11::
  SoundSet, -1
  SoundPlay,*64
  return

RShift & F10::
  Send,{Volume_Mute}
  SoundPlay,*64
  return

F13 & `;::
  terminal := WinExist("ahk_exe WindowsTerminal.exe")
  if (terminal)
  {
    active := WinActive("ahk_id " terminal)
    if (active)
      WinMinimize, ahk_id %active%
    else
      WinActivate, ahk_id %terminal%
  }
  else
    Run, wt.exe
Return
