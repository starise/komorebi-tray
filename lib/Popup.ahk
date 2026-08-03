Class Popup
{
  static WM_GETFONT := 0x0031 ; Read the font selected by the text control.
  static SWP_NOACTIVATE := 0x0010 ; Move without activating the window.

  ; Default popup appearance and timing.
  static DEFAULT_FONT_SIZE := 11
  static DEFAULT_FONT_NAME := "Segoe UI"
  static DEFAULT_FONT_COLOR := "white"
  static DEFAULT_BG_COLOR := "242424"
  static DEFAULT_TIMER := 2000
  static PADDING_X := 24
  static PADDING_Y := 16
  static BOTTOM_OFFSET := 120

  static gui := "" ; Persistent GUI instance.
  static textControl := "" ; Reused message control.
  static hwnd := 0 ; Native GUI window handle.
  static font := 0 ; Native font handle used by DrawText.
  static hideTimer := "" ; One-shot callback that conceals the popup.
  static styleKey := "" ; Avoid reapplying an unchanged style.
  static chromeWidth := 0 ; Horizontal non-client border size.
  static chromeHeight := 0 ; Vertical non-client border size.

  ; Keep one transparent GUI alive for the process lifetime. Popup updates never
  ; call Show/Hide, which avoids Windows launch-feedback cursor activation.
  static initialize() {
    if (this.hwnd) {
      return
    }

    ; Extended window styles:
    ; https://learn.microsoft.com/windows/win32/winmsg/extended-window-styles
    ; -DPIScale aligns GUI coordinates with SetWindowPos physical pixels.
    ; 0x08000020 = WS_EX_NOACTIVATE | WS_EX_TRANSPARENT:
    ; no activation; same-thread siblings paint first.
    this.gui := Gui(
      "-Caption +ToolWindow +AlwaysOnTop +Border -DPIScale"
      " +E0x08000020"
    )
    ; SS_NOPREFIX (0x80) renders ampersands literally instead of as accelerators.
    this.textControl := this.gui.Add(
      "Text",
      "Center BackgroundTrans +0x80",
      ""
    )
    this.hwnd := this.gui.Hwnd
    this.hideTimer := ObjBindMethod(this, "hide")
    this.applyStyle(
      this.DEFAULT_FONT_SIZE,
      this.DEFAULT_FONT_COLOR,
      this.DEFAULT_BG_COLOR
    )

    ; Show exactly once outside every monitor, then make it fully transparent.
    ; Keeping the HWND shown avoids re-triggering the Windows AppStarting
    ; launch-feedback cursor.
    this.gui.Show("NoActivate x-32000 y-32000 w100 h100")
    WinSetTransparent(0, "ahk_id " this.hwnd)
    this.measureChrome()
  }

  ; Update and reveal the persistent popup without showing or recreating it.
  static new(
    message,
    timer := this.DEFAULT_TIMER,
    fontSize := this.DEFAULT_FONT_SIZE,
    fontColor := this.DEFAULT_FONT_COLOR,
    bgColor := this.DEFAULT_BG_COLOR,
    monitor := 1
  ) {
    this.initialize()
    this.applyStyle(fontSize, fontColor, bgColor)
    textSize := this.measure(message)
    width := textSize.width + this.PADDING_X * 2 + this.chromeWidth
    height := textSize.height + this.PADDING_Y * 2 + this.chromeHeight
    MonitorGetWorkArea(monitor, &left, &top, &right, &bottom)

    this.textControl.Value := message
    ; Place the text inside the client-area padding.
    this.textControl.Move(
      this.PADDING_X,
      this.PADDING_Y,
      textSize.width,
      textSize.height
    )
    ; Move and resize the existing topmost HWND without activating it.
    ; https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-setwindowpos
    DllCall(
      "User32\SetWindowPos",
      "Ptr", this.hwnd, ; Window to move and resize.
      "Ptr", -1, ; HWND_TOPMOST
      "Int", Round((left + right - width) / 2), ; Final x position.
      "Int", bottom - height - this.BOTTOM_OFFSET, ; Final y position.
      "Int", width, ; Outer window width.
      "Int", height, ; Outer window height.
      "UInt", this.SWP_NOACTIVATE ; Preserve foreground focus.
    )
    WinSetTransparent(255, "ahk_id " this.hwnd)
    ; Restart the one-shot hide timer for rapid consecutive workspace changes.
    SetTimer(this.hideTimer, 0)
    SetTimer(this.hideTimer, -timer)
  }

  ; Apply configurable style and cache the native font used for measurement.
  static applyStyle(fontSize, fontColor, bgColor) {
    styleKey := fontSize "|" fontColor "|" bgColor
    if (styleKey = this.styleKey) {
      return
    }

    this.gui.BackColor := bgColor
    this.textControl.SetFont(
      "s" fontSize " c" fontColor,
      this.DEFAULT_FONT_NAME
    )
    ; Ask the text control for the actual font selected by SetFont.
    this.font := DllCall(
      "User32\SendMessage",
      "Ptr", this.textControl.Hwnd, ; Target control handle.
      "UInt", this.WM_GETFONT, ; Message identifier.
      "Ptr", 0, ; Unused wParam.
      "Ptr", 0, ; Unused lParam.
      "Ptr" ; Return type: selected font handle.
    )
    this.styleKey := styleKey
  }

  ; SetWindowPos expects outer dimensions; controls use client dimensions.
  ; Measure the non-client border instead of assuming a DPI-dependent size.
  static measureChrome() {
    windowRect := Buffer(16, 0)
    clientRect := Buffer(16, 0)
    ; Read outer and drawable rectangles to derive the real border thickness.
    DllCall("User32\GetWindowRect", "Ptr", this.hwnd, "Ptr", windowRect)
    DllCall("User32\GetClientRect", "Ptr", this.hwnd, "Ptr", clientRect)
    this.chromeWidth := NumGet(windowRect, 8, "Int")
      - NumGet(windowRect, 0, "Int") - NumGet(clientRect, 8, "Int")
    this.chromeHeight := NumGet(windowRect, 12, "Int")
      - NumGet(windowRect, 4, "Int") - NumGet(clientRect, 12, "Int")
  }

  ; Measure before moving the transparent window to its final position.
  ; https://learn.microsoft.com/windows/win32/api/winuser/nf-winuser-drawtext
  static measure(message) {
    ; Use the screen device context with the same font as the GUI control.
    screenDC := DllCall("User32\GetDC", "Ptr", 0, "Ptr")
    oldFont := DllCall(
      "Gdi32\SelectObject",
      "Ptr", screenDC, ; Screen device context.
      "Ptr", this.font, ; Font used by the popup text.
      "Ptr" ; Return type: previous font handle.
    )
    rect := Buffer(16, 0)
    DllCall(
      "User32\DrawText",
      "Ptr", screenDC, ; Device context used for measurement.
      "Str", message, ; Text to measure.
      "Int", -1, ; Read the full null-terminated string.
      "Ptr", rect, ; Receives the calculated bounds.
      "UInt", 0x0400 | 0x0800 ; DT_CALCRECT honors line breaks; DT_NOPREFIX keeps '&' literal.
    )
    ; Restore the device context and release the borrowed screen DC.
    DllCall("Gdi32\SelectObject", "Ptr", screenDC, "Ptr", oldFont)
    DllCall("User32\ReleaseDC", "Ptr", 0, "Ptr", screenDC)

    return {
      width: NumGet(rect, 8, "Int"),
      height: NumGet(rect, 12, "Int")
    }
  }

  ; Never call Gui.Hide: make the live HWND transparent and move it off-screen.
  static hide(*) {
    if ( not this.hwnd) {
      return
    }
    WinSetTransparent(0, "ahk_id " this.hwnd)
    DllCall(
      "User32\SetWindowPos",
      "Ptr", this.hwnd, ; Window to move and resize.
      "Ptr", 0, ; HWND_TOP.
      "Int", -32000, ; Off-screen x position.
      "Int", -32000, ; Off-screen y position.
      "Int", 1, ; Minimal off-screen window width.
      "Int", 1, ; Minimal off-screen window height.
      "UInt", this.SWP_NOACTIVATE ; Preserve foreground focus.
    )
  }

  ; Explicit final cleanup for tests or application shutdown only.
  static destroy() {
    if (this.hideTimer) {
      SetTimer(this.hideTimer, 0)
    }
    if (this.gui) {
      this.gui.Destroy()
    }
    this.gui := ""
    this.textControl := ""
    this.hwnd := 0
    this.font := 0
    this.hideTimer := ""
    this.styleKey := ""
  }
}
