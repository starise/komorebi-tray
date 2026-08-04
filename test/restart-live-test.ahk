#Requires AutoHotkey v2.0
#SingleInstance Force
#ErrorStdOut

#Include ..\lib\KomorebiTray.ahk

KomorebiTray.restart()
pid := Komorebi.isRunning
if (not pid) {
  FileAppend("Komorebi did not restart.`n", "*")
  ExitApp(1)
}

Sleep(10000)
if (not ProcessExist(pid)) {
  FileAppend("The restarted Komorebi process exited early.`n", "*")
  ExitApp(1)
}

ExitApp(0)
