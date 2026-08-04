#Requires AutoHotkey v2.0

trayIconPath := ""
TraySetIcon(path) {
  global trayIconPath
  trayIconPath := path
}

#Include ..\lib\KomorebiTray.ahk

KomorebiTray.darkMode := false
if (not InStr(KomorebiTray.iconPath("d-1"), "\images\ico\light\ws-01-light.ico")) {
  throw Error("Light workspace icon mapping failed.")
}

KomorebiTray.setIcon("d-9")
if (KomorebiTray.currentIcon != "app" or not InStr(trayIconPath, "\images\ico\light\app-light.ico")) {
  throw Error("Overflow workspace icon fallback failed.")
}

KomorebiTray.darkMode := true
if (not InStr(KomorebiTray.iconPath("pause"), "\images\ico\dark\pause-dark.ico")) {
  throw Error("Dark pause icon mapping failed.")
}

if (not KomorebiTray.applyMenuTheme()) {
  ExitApp(1)
}

if (not KomorebiTray.flushMenuThemes()) {
  ExitApp(1)
}
