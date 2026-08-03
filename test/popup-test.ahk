#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\lib\Popup.ahk

Popup.initialize()
popupHwnd := Popup.hwnd
Popup.new("Lifecycle check", 50)
if (Popup.hwnd != popupHwnd) {
  throw Error("Popup HWND was recreated.")
}
Sleep(100)
if (WinGetTransparent("ahk_id " popupHwnd) != 0) {
  throw Error("Popup did not become transparent.")
}

singleLine := Popup.measure("Message")
multipleLines := Popup.measure("Message`nMessage")
if (multipleLines.height <= singleLine.height) {
  throw Error("Popup multiline measurement failed.")
}

if (MonitorGetCount() > 1) {
  Popup.new("Second monitor", 50, , , , 2)
  MonitorGetWorkArea(2, &left, &top, &right, &bottom)
  WinGetPos(&x, &y, &width, &height, "ahk_id " popupHwnd)
  if (x != Round((left + right - width) / 2)
    or y != bottom - height - Popup.BOTTOM_OFFSET) {
    throw Error("Popup was not placed on the requested monitor.")
  }
}

Popup.new("Message 1", 2000)

Sleep(500)

Popup.new("Message changed`nbefore timeout", 2000)

Sleep(2500)

Popup.new("Message after timeout", 2000)

Sleep(2000)

Popup.destroy()
