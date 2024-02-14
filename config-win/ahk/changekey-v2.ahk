; REMOVED: #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Requires AutoHotkey v2.0
#Warn  ;Enable warnings to assist with detecting common errors.
#SingleInstance force
InstallKeybdHook()
#WinActivateForce
#UseHook
SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.
DetectHiddenWindows(true)
SetWinDelay(0)
SetTitleMatchMode("RegEx")

;ChangeKeyで左WinキーにF13(0064)を、右WinキーにF14(0065)を割り当てている想定

;Shift  +
;Ctrl   ^
;Alt    !
;Win    #

;特殊なキー http://ahkwiki.net/KeyList

;; LWin を Mac Command キーのように使う
F13 & a::^a
F13 & b::^b
F13 & c::^c
F13 & d::^d
F13 & e::^e
F13 & f::^f
F13 & g::^g
F13 & h::{
  if GetKeyState("Alt") {
    Send("#{Home}")
    Return
  }
  Send("#{Down}")
  Return
}
F13 & i::^i
F13 & j::^j
F13 & k::^k
F13 & l::^l
F13 & m::WinMinimize "A"
F13 & n::^n
F13 & o::^o
F13 & p::^p
F13 & q::!F4
F13 & r::^r
F13 & s::^s
F13 & t::^t
F13 & u::^u
F13 & v::^v
F13 & w::^w
F13 & x::^x
F13 & y::^y
F13 & z::^z

F13 & 1::^1
F13 & 2::^2
F13 & 3::
{
  if GetKeyState("Shift") {
    Send("#{PrintScreen}")
    Return
  }
  Send("^3")
  Return
}
F13 & 4::
{
  if GetKeyState("Shift") {
    Send("#+s") ;切り取り＆スケッチ
    Return
  }
  Send("^4")
  Return
}
F13 & 5::^5
F13 & 6::^6
F13 & 7::^7
F13 & 8::^8
F13 & 9::^9
F13 & 0::^0

F13 & Enter::^Enter
F13 & /::^/
F13 & [::
{
  if GetKeyState("Shift") {
    Send("^{PgUp}")
    Return
  }
  Send("^[")
  Return
}
F13 & ]::
{
  if GetKeyState("Shift") {
    Send("^{PgDn}")
    Return
  }
  Send("^]")
  Return
}
F13 & +::^= ; 若干自信ない
F13 & -::^-
F13 & ,::^,
F13 & .::^.
; 単語移動
F13 & Right::^Right
F13 & Left::^Left

; 特殊系
F13 & BackSpace::Send("+{Home}{BackSpace}")

; 仮想デスクトップの移動
^Right::^#Right
^Left::^#Left

;;RWin を 普通Windowsキーのように使う
; スタートメニュー使いたいときは C-Esc を使う
F14 & a::#a
F14 & b::#b
F14 & c::#c
F14 & d::#d
F14 & e::#e
F14 & f::#f
F14 & g::#g
F14 & h::#h
F14 & i::#i
F14 & j::#j
F14 & k::#k
F14 & l::#l
F14 & m::#m
F14 & n::#n
F14 & o::#o
F14 & p::#p
F14 & q::#q
F14 & r::#r
F14 & s::#s
F14 & t::#t
F14 & u::#u
F14 & v::#v
F14 & w::#w
F14 & x::#x
F14 & y::#y
F14 & z::#z
F14 & 1::#1
F14 & 2::#2
F14 & 3::#3
F14 & 4::#4
F14 & 5::#5
F14 & 6::#6
F14 & 7::#7
F14 & 8::#8
F14 & 9::#9
F14 & 0::#0
F14 & Left::#Left
F14 & Right::#Right
F14 & Up::#Up
F14 & Down::#Down
F14 & Space::#Space
F14 & .::#.

;; Emacs like
#HotIf !WinActive("ahk_exe (ubuntu2204|bash|emacs|WindowsTerminal).exe")
  ^p::  Send("{Up}")
  ^n::  Send("{Down}")
  ^f::  Send("{Right}")
  ^b::  Send("{left}")
  ^a::  Send("{Home}")
  ^e::  Send("{End}")
  ^v::  Send("{PgDn}")
  !v::  Send("{PgUp}")
  !,::  Send("^{Home}")
  !.::  Send("^{End}")

  +^p::  Send("+{Up}")
  +^n::  Send("+{Down}")
  +^f::  Send("+{Right}")
  +^b::  Send("+{left}")
  +^a::  Send("+{Home}")
  +^e::  Send("+{End}")
  +^v::  Send("+{PgDn}")
  +!v::  Send("+{PgUp}")
  +!,::  Send("+^{Home}")
  +!.::  Send("+^{End}")

  +BackSpace::  Send("{Delete}")

  ^d::  Send("{Delete}")
  ^h::  Send("{BackSpace}")
  ^w::^x
  ^y::^v
  ^s::^f
  ^/::^z
  ^k::  Send("+{End}^x")
  ^m::  Send("{Enter}")
  ^j::  Send("{Enter}")
#HotIf

!BackSpace::  Send("^{BackSpace}")

;-----------------------------------------------------------
; IMEの状態をセット
;   SetSts          1:ON / 0:OFF
;   WinTitle="A"    対象Window
;   戻り値          0:成功 / 0以外:失敗
;-----------------------------------------------------------
IME_SET(SetSts, WinTitle:="A"){
    if !(WinActive(WinTitle))
        return -1

    hwnd := WinGetID
    ptrSize := !A_PtrSize ? 4 : A_PtrSize
    cbSize:=4+4+(PtrSize*6)+16
    stGTI := Buffer(cbSize, 0)
    NumPut("UInt", cbSize, stGTI, 0)   ;	DWORD   cbSize;
    hwnd := DllCall("GetGUIThreadInfo", "Uint",0, "Uint", stGTI.Ptr)
                ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd

    return DllCall("SendMessage"
          , "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "Uint",hwnd)
          , "UInt", 0x0283  ;Message : WM_IME_CONTROL
          ,  "Int", 0x006   ;wParam  : IMC_SETOPENSTATUS
          ,  "Int", SetSts) ;lParam  : 0 or 1
}

F13::IME_SET(0)
F14 up::IME_SET(1)
^[::
{
Send("{Escape}")
IME_SET(0)
Return
}

F13 & Tab::AltTab
!Tab::Send("#{Tab}")

; LWin+Click -> Ctrl+Click
F13 & LButton::
{
  MouseGetPos(&x, &y)
  Send "^{Click %x% %y%}"
}

; LWin+スクロール -> Ctrl+スクロール
F13 & WheelUp::Send "^{WheelUp}"
F13 & WheelDown::Send "^{WheelDown}"

; sound volume
RShift & F12::
{
  SoundSetVolume("+5")
  SoundPlay("*64")
  return
}

RShift & F11::
{
  SoundSetVolume(-5)
  SoundPlay("*64")
  return
}

RShift & F10::
{
  Send("{Volume_Mute}")
  SoundPlay("*64")
  return
}

; WindowsTerminal 切り替え
F13 & `;::
{
  terminal := WinExist("ahk_class CASCADIA_HOSTING_WINDOW_CLASS")
  ; terminal := WinExist("ahk_exe WindowsTerminal.exe")
  if (terminal)
  {
    active := WinActive("ahk_id " terminal)
    if (active)
      WinMinimize("ahk_id " active)
    else
      WinActivate("ahk_id " terminal)
  }
  else
    Run("wt.exe")
  return
}

#HotIf WinActive("ahk_exe Code.exe")
  ; Ctrl + ` でターミナルを開くように設定しておく
  $^SC029::  Send("^'")
#HotIf

#HotIf WinActive("ahk_exe WindowsTerminal.exe")
  F13 & n::  Send("^+n")
  F13 & t::  Send("^+t")
  F13 & w::  Send("^+w")
  F13 & f::  Send("^+f")
  F13 & d::  Send("^+d")
#HotIf

#HotIf WinActive("ahk_exe chrome.exe")
  F13 & y::  Send("^h") ; 履歴
  F13 & i:: {
    if GetKeyState("Alt") {
      ; DevTools を開く
      Send("^+i")
      Return
    }
    Send("^i")
    Return
  }
#HotIf

; Kindle ページめくり
; うまくいかないときは移動のウィンドウを閉じれば動く
!] up::
{
  hWnd := WinExist(".*Kindle for PC.*")
  if (hWnd)
  {
    ControlSend("{Right}", hWnd)
  }
}

![ up::
{
  hWnd := WinExist(".*Kindle for PC.*")
  if (hWnd)
  {
    ControlSend("{Left}", hWnd)
  }
}

#HotIf WinActive("ahk_exe Kindle.exe")
  [::Send("{Left}")
  ]::Send("{Right}")
#HotIf

;; 定型文

; 高速に文字列を挿入する
; ref: https://did2memo.net/2014/03/19/autohotkey-insert-text/
InsertText(Content) {
  cb_bk := ClipboardAll()
  A_Clipboard := Content
  Send("^v")
  Sleep(100)
  A_Clipboard := cb_bk
}

; 終了文字なしで発動
#HotString *

::`;dd::
{
  TimeString := FormatTime(, "yyyyMMdd")
  InsertText(TimeString)
  Return
}

::`;yoro::
{
  InsertText("よろしくお願いいたします。")
  Return
}

::`;cb::
{
  InsertText("```````n" A_Clipboard "`n```````n")
  Return
}
