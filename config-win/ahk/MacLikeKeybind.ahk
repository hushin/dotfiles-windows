#SingleInstance force
#InstallKeybdHook
#UseHook
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
