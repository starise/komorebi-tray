#Requires AutoHotkey v2.0
#SingleInstance Force
#ErrorStdOut

#Include ..\lib\Komorebi.ahk

Komorebi.CONFIG_HOME := A_ScriptDir "\fixtures"
Komorebi.startConfigAhk()
firstPid := Komorebi.configAhkPid
if (not firstPid or not ProcessExist(firstPid)) {
  FileAppend("The profile did not start.`n", "*")
  ExitApp(1)
}

Komorebi.startConfigAhk()
pid := Komorebi.configAhkPid
if (pid = firstPid or ProcessExist(firstPid) or not ProcessExist(pid)) {
  FileAppend("The previous profile outlived its replacement.`n", "*")
  ExitApp(1)
}

Komorebi.stopConfigAhk()
if (ProcessExist(pid)) {
  FileAppend("The profile outlived its owner.`n", "*")
  ExitApp(1)
}

ExitApp(0)
