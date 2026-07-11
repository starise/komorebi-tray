#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

Komorebic(cmd) {
  RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

MouseOnTaskbar() {
  MouseGetPos(, , &hoverID)
  taskbarPrimaryID := WinExist("ahk_class Shell_TrayWnd")
  taskbarSecondaryID := WinExist("ahk_class Shell_SecondaryTrayWnd")
  return (hoverID == taskbarPrimaryID or hoverID == taskbarSecondaryID)
}

; Cycle workspaces with mouse wheel on taskbar
#HotIf MouseOnTaskbar()
WheelUp:: Komorebic("cycle-workspace previous")
WheelDown:: Komorebic("cycle-workspace next")
#HotIf

; Disable default virtual desktop shortcuts
#Tab:: Send("{Alt down}{Tab}{Alt up}")
^#F4:: return
^#d:: return

; Window manager
#q:: Komorebic("close")
#m:: Komorebic("minimize")
#Del:: Komorebic("retile")
#End:: Komorebic("toggle-pause")

; Manipulate windows
F11:: Komorebic("toggle-maximize")
#f:: Komorebic("toggle-monocle")
^#f:: Komorebic("toggle-float")

; Resize
!=:: Komorebic("resize-axis horizontal increase")
!-:: Komorebic("resize-axis horizontal decrease")
!+=:: Komorebic("resize-axis vertical increase")
!+_:: Komorebic("resize-axis vertical decrease")

; Layouts
#x:: Komorebic("flip-layout horizontal")
#z:: Komorebic("flip-layout vertical")

; Move windows
#+Up:: Komorebic("move up")
#+Down:: Komorebic("move down")
#+Left:: Komorebic("move left")
#+Right:: Komorebic("move right")

; Focus windows
#Left:: Komorebic("focus left")
#Down:: Komorebic("focus down")
#Up:: Komorebic("focus up")
#Right:: Komorebic("focus right")

; Stack windows
#!Left:: Komorebic("stack left")
#!Down:: Komorebic("stack down")
#!Up:: Komorebic("stack up")
#!Right:: Komorebic("stack right")
#!End:: Komorebic("unstack")

#!PgUp:: Komorebic("cycle-stack previous")
#!PgDn:: Komorebic("cycle-stack next")

; Workspaces
#1:: Komorebic("focus-workspace 0")
#2:: Komorebic("focus-workspace 1")
#3:: Komorebic("focus-workspace 2")
#4:: Komorebic("focus-workspace 3")
#5:: Komorebic("focus-workspace 4")
#6:: Komorebic("focus-workspace 5")
#7:: Komorebic("focus-workspace 6")
#8:: Komorebic("focus-workspace 7")

^#Left:: Komorebic("cycle-workspace previous")
^#Right:: Komorebic("cycle-workspace next")

; Move windows across workspaces
#+1:: Komorebic("move-to-workspace 0")
#+2:: Komorebic("move-to-workspace 1")
#+3:: Komorebic("move-to-workspace 2")
#+4:: Komorebic("move-to-workspace 3")
#+5:: Komorebic("move-to-workspace 4")
#+6:: Komorebic("move-to-workspace 5")
#+7:: Komorebic("move-to-workspace 6")
#+8:: Komorebic("move-to-workspace 7")

^#+Left:: Komorebic("cycle-move-to-workspace previous")
^#+Right:: Komorebic("cycle-move-to-workspace next")
