Class Popup
{
  ; Fade-in animation flag.
  static AW_FADE_IN := 0x00080000
  ; Fade-out animation flag.
  static AW_FADE_OUT := 0x00090000

  ; Default style settings
  static DEFAULT_FONT_SIZE := "10"
  static DEFAULT_FONT_NAME := "Segoe UI"
  static DEFAULT_FONT_COLOR := "white"
  static DEFAULT_BG_COLOR := "242424"
  static DEFAULT_TIMER := 2000

  ; Current message to show.
  static message := ""
  ; Current popup Gui instance.
  static Gui := Gui()
  ; Popup message ID.
  static ID := 0
  ; Animation time to be shown (in ms).
  static animationTime := 10

  ; Create and show a popup message on-screen.
  static new(
    message,
    timer := this.DEFAULT_TIMER,
    fontSize := this.DEFAULT_FONT_SIZE,
    fontColor := this.DEFAULT_FONT_COLOR,
    bgColor := this.DEFAULT_BG_COLOR
  ) {
    this.message := message
    this.fontSize := fontSize
    this.fontColor := fontColor
    this.bgColor := bgColor

    this.cleanCache()

    DetectHiddenWindows(true)
    MonitorGetWorkArea(, &workspaceLeft, &workspaceTop, &workspaceRight, &workspaceBottom)
    this.Gui.Opt("-Caption +ToolWindow +LastFound +AlwaysOnTop +Border")
    this.Gui.BackColor := bgColor
    this.Gui.SetFont(Format("s{1} c{2}", fontSize, fontColor), this.DEFAULT_FONT_NAME)
    this.Gui.Add("Text", "Center", message)
    this.Gui.Show("Hide")
    this.ID := WinExist()
    WinGetPos(&guiX, &guiY, &guiWidth, &guiHeight, "ahk_id " this.ID)
    NewX := (workspaceRight - guiWidth) / 2
    NewY := workspaceBottom - guiHeight - 120
    this.Gui.Show("Hide x" . NewX . " y" . NewY)

    this.push()
    this.hide(timer)
  }

  ; Animate (show or hide) the current popup.
  ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-animatewindow
  static animate(flag) {
    DllCall(
      "AnimateWindow",
      "UInt", this.ID, ; A handle to the window to animate.
      "Int", this.animationTime, ; Time to play the animation, in milliseconds.
      "UInt", flag ; Animation type flag
    )
  }

  ; If a popup already exists, destroy it.
  static cleanCache() => this.ID ? this.destroy() : false

  ; Helpers to trigger show/hide animations
  static push() => this.animate(this.AW_FADE_IN)
  static pull() => this.animate(this.AW_FADE_OUT)

  ; Hide current popup message after a certain time.
  static hide(timer := this.DEFAULT_TIMER) {
    this.instance := ObjBindMethod(this, "pull")
    SetTimer(this.instance, timer)
  }

  ; Destroy current popup.
  static destroy() {
    SetTimer(this.instance, 0)
    this.Gui.Destroy()
    this.Gui := Gui()
  }
}
