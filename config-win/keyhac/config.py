# keyhac config file
# https://crftwr.github.io/keyhac/doc/ja/index.html
import sys
import os
import datetime

import pyauto
from keyhac import *

def configure(keymap):
    keymap.editor = "notepad.exe"
    keymap.setFont("MS Gothic", 14)
    keymap.setTheme("black")

    keymap_global = keymap.defineWindowKeymap()
    def ime_on():
        keymap.wnd.setImeStatus( 1 )

    def ime_off():
        keymap.wnd.setImeStatus( 0 )

    not_emacs_target = [
        "bash.exe",
        "emacs.exe",
        "ubuntu2004.exe",
        "WindowsTerminal.exe",
    ]

    def is_emacs_target(window):
        if window.getProcessName() in not_emacs_target:
            return False
        return True
    keymap_emacs = keymap.defineWindowKeymap(check_func=is_emacs_target)

    # Cursor
    keymap_emacs[ "C-P" ] = "Up"
    keymap_emacs[ "C-N" ] = "Down"
    keymap_emacs[ "C-F" ] = "Right"
    keymap_emacs[ "C-B" ] = "Left"
    keymap_emacs[ "C-A" ] = "Home"
    keymap_emacs[ "C-E" ] = "End"
    keymap_emacs[ "C-V" ] = "PageDown"
    keymap_emacs[ "A-V" ] = "PageUp"
    keymap_emacs[ "A-Comma" ] = "C-Home"
    keymap_emacs[ "A-Period" ] = "C-End"
    keymap_emacs[ "S-C-P" ] = "S-Up"
    keymap_emacs[ "S-C-N" ] = "S-Down"
    keymap_emacs[ "S-C-F" ] = "S-Right"
    keymap_emacs[ "S-C-B" ] = "S-Left"
    keymap_emacs[ "S-C-A" ] = "S-Home"
    keymap_emacs[ "S-C-E" ] = "S-End"
    keymap_emacs[ "S-C-V" ] = "S-PageDown"
    keymap_emacs[ "S-A-V" ] = "S-PageUp"
    keymap_emacs[ "S-A-Comma" ] = "S-C-Home"
    keymap_emacs[ "S-A-Period" ] = "S-C-End"
    keymap_emacs[ "S-Back" ] = "Delete"

    # Ctrl bindings
    keymap_emacs[ "C-D" ] = "Delete"       # Delete
    keymap_emacs[ "C-H" ] = "Back"         # Backspace
    keymap_emacs[ "C-W" ] = "C-X"          # Cut
    keymap_emacs[ "C-Y" ] = "C-V"          # Paste
    keymap_emacs[ "C-S" ] = "C-F"          # Search
    keymap_emacs[ "C-(191)" ] = "C-Z"      # Undo
    keymap_emacs[ "C-K" ] = "S-End","C-X"  # Removing following text
    keymap_emacs[ "C-J" ] = "Enter"
    keymap_emacs[ "C-OpenBracket" ] = "Esc"

    # Win キー(ChangeKey でF13に割り当て済み)を Mac のCmdのように割当
    keymap.defineModifier( 124, "User0" )

    # U-LW/RW : 離した時にスタートメニュー非表示
    # スタートメニュー使いたい > C-Esc
    keymap_global[ "U-RWin" ] = "RW-RShift"

    # O- LW/RW : LW/RW 押した時にIME off/on
    # 他のキーと押した時は、元のキー扱い
    keymap_global[ "O-(124)" ] = ime_off
    keymap_global[ "O-RWin" ] = ime_on

    # LWin as Command
    def setLWKey(key, modifiers=["C", "S-C", "A-C"]):
        for modifier in modifiers:
            if modifier == "C":
                keymap_global[ f"U0-{key}" ] = f"C-{key}"
            elif modifier == "S-C":
                keymap_global[ f"S-U0-{key}" ] = f"S-C-{key}"
            elif modifier == "A-C":
                keymap_global[ f"A-U0-{key}" ] = f"A-C-{key}"

    setLWKey("(191)") # C-/
    setLWKey("A")  # Select All
    setLWKey("B")
    setLWKey("C")  # Copy
    setLWKey("D")
    setLWKey("E")
    setLWKey("F")
    setLWKey("G")
    setLWKey("I")
    setLWKey("K")
    setLWKey("L")
    setLWKey("N")
    setLWKey("O")
    setLWKey("P")
    keymap_global[ "U0-Q" ] = "A-F4"
    setLWKey("R")
    setLWKey("S")  # Save
    setLWKey("T")
    setLWKey("U")
    setLWKey("V")  # Paste
    setLWKey("W")  # Close Tab
    setLWKey("X")  # Cut
    setLWKey("Y")
    setLWKey("Z")

    setLWKey("Enter")
    setLWKey("OpenBracket")
    setLWKey("CloseBracket")
    setLWKey("Plus")
    setLWKey("Minus")
    setLWKey("Comma")

    # Tabs
    setLWKey("1")
    setLWKey("2")
    setLWKey("3")
    setLWKey("4")
    setLWKey("5")
    setLWKey("6")
    setLWKey("7")
    setLWKey("8")
    setLWKey("9")
    setLWKey("0")

    keymap_global[ "U0-Back" ] = "S-Home", "Back"
    keymap_global[ "S-U0-CloseBracket" ] = "C-PageDown"
    keymap_global[ "S-U0-OpenBracket" ] = "C-PageUp"
    keymap_global[ "S-U0-3" ] = "PrintScreen"
    keymap_global[ "S-U0-4" ] = "W-S-S"
    keymap_global[ "A-U0-I" ] = "S-C-I" # Chome Devtool

    # 仮想デスクトップの移動
    keymap_global[ "C-Right"  ] = "C-W-Right"
    keymap_global[ "C-Left"   ] = "C-W-Left"
    keymap_global[ "U0-Right" ] = "C-Right"
    keymap_global[ "U0-Left"  ] = "C-Left"

    # VSCode
    keymap_vscode = keymap.defineWindowKeymap( exe_name="code.exe")
    # VSCode + US配列キーボードの組み合わせだと動作しないものがあるので、別のショートカットを追加して割当
    # Win-Shift-Enter
    keymap_vscode[ "S-U0-Enter" ] = "W-S-Quote"
    # Ctrl-`
    keymap_vscode[ "LC-(244)" ] =  "W-S-Semicolon"


    # Windows Terminal
    keymap_wt = keymap.defineWindowKeymap( exe_name="WindowsTerminal.exe")
    keymap_wt[ "U0-N" ] = "C-S-N"
    keymap_wt[ "U0-W" ] = "C-S-W"
    keymap_wt[ "U0-F" ] = "C-S-F"
    keymap_wt[ "U0-D" ] = "C-S-D"

    # Clipboard history related
    keymap_global[ "U0-S-V"   ] = keymap.command_ClipboardList     # Open the clipboard history list
    keymap_global[ "C-S-X"   ] = keymap.command_ClipboardRotate   # Move the most recent history to tail
    keymap_global[ "C-S-A-X" ] = keymap.command_ClipboardRemove   # Remove the most recent history
    keymap.quote_mark = "> "                                      # Mark for quote pasting

    # Customizing clipboard history list
    if 1:
        # Enable clipboard monitoring hook (Default:Enabled)
        keymap.clipboard_history.enableHook(True)

        # Maximum number of clipboard history (Default:1000)
        keymap.clipboard_history.maxnum = 1000

        # Total maximum size of clipboard history (Default:10MB)
        keymap.clipboard_history.quota = 10*1024*1024

        # Fixed phrases
        fixed_items = [
            ( "name@server.net",     "name@server.net" ),
            ( "Address",             "San Francisco, CA 94128" ),
            ( "Phone number",        "03-4567-8901" ),
        ]

        # Return formatted date-time string
        def dateAndTime(fmt):
            def _dateAndTime():
                return datetime.datetime.now().strftime(fmt)
            return _dateAndTime

        # Date-time
        datetime_items = [
            ( "YYYY/MM/DD HH:MM:SS",   dateAndTime("%Y/%m/%d %H:%M:%S") ),
            ( "YYYY/MM/DD",            dateAndTime("%Y/%m/%d") ),
            ( "HH:MM:SS",              dateAndTime("%H:%M:%S") ),
            ( "YYYYMMDD_HHMMSS",       dateAndTime("%Y%m%d_%H%M%S") ),
            ( "YYYYMMDD",              dateAndTime("%Y%m%d") ),
            ( "HHMMSS",                dateAndTime("%H%M%S") ),
        ]

        # Add quote mark to current clipboard contents
        def quoteClipboardText():
            s = getClipboardText()
            lines = s.splitlines(True)
            s = ""
            for line in lines:
                s += keymap.quote_mark + line
            return s

        # Indent current clipboard contents
        def indentClipboardText():
            s = getClipboardText()
            lines = s.splitlines(True)
            s = ""
            for line in lines:
                if line.lstrip():
                    line = " " * 4 + line
                s += line
            return s

        # Unindent current clipboard contents
        def unindentClipboardText():
            s = getClipboardText()
            lines = s.splitlines(True)
            s = ""
            for line in lines:
                for i in range(4+1):
                    if i>=len(line) : break
                    if line[i]=='\t':
                        i+=1
                        break
                    if line[i]!=' ':
                        break
                s += line[i:]
            return s

        full_width_chars = "ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ！”＃＄％＆’（）＊＋，−．／：；＜＝＞？＠［￥］＾＿‘｛｜｝～０１２３４５６７８９　"
        half_width_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\]^_`{|}～0123456789 "

        # Convert to half-with characters
        def toHalfWidthClipboardText():
            s = getClipboardText()
            s = s.translate(str.maketrans(full_width_chars,half_width_chars))
            return s

        # Convert to full-with characters
        def toFullWidthClipboardText():
            s = getClipboardText()
            s = s.translate(str.maketrans(half_width_chars,full_width_chars))
            return s

        # Save the clipboard contents as a file in Desktop directory
        def command_SaveClipboardToDesktop():

            text = getClipboardText()
            if not text: return

            # Convert to utf-8 / CR-LF
            utf8_bom = b"\xEF\xBB\xBF"
            text = text.replace("\r\n","\n")
            text = text.replace("\r","\n")
            text = text.replace("\n","\r\n")
            text = text.encode( encoding="utf-8" )

            # Save in Desktop directory
            fullpath = os.path.join( getDesktopPath(), datetime.datetime.now().strftime("clip_%Y%m%d_%H%M%S.txt") )
            fd = open( fullpath, "wb" )
            fd.write(utf8_bom)
            fd.write(text)
            fd.close()

            # Open by the text editor
            keymap.editTextFile(fullpath)

        # Menu item list
        other_items = [
            ( "Quote clipboard",            quoteClipboardText ),
            ( "Indent clipboard",           indentClipboardText ),
            ( "Unindent clipboard",         unindentClipboardText ),
            ( "",                           None ),
            ( "To Half-Width",              toHalfWidthClipboardText ),
            ( "To Full-Width",              toFullWidthClipboardText ),
            ( "",                           None ),
            ( "Save clipboard to Desktop",  command_SaveClipboardToDesktop ),
            ( "",                           None ),
            ( "Edit config.py",             keymap.command_EditConfig ),
            ( "Reload config.py",           keymap.command_ReloadConfig ),
        ]

        # Clipboard history list extensions
        keymap.cblisters += [
            ( "Fixed phrase", cblister_FixedPhrase(fixed_items) ),
            ( "Date-time", cblister_FixedPhrase(datetime_items) ),
            ( "Others", cblister_FixedPhrase(other_items) ),
        ]

