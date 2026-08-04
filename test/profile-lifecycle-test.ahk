#Requires AutoHotkey v2.0
#SingleInstance Force
#ErrorStdOut

#Include ..\lib\Komorebi.ahk

profilePath := A_ScriptDir "\fixtures\komorebi.ahk"
Komorebi.startConfigAhk(profilePath)
firstPid := Komorebi.configAhkPid
if (not firstPid or not ProcessExist(firstPid)) {
  FileAppend("The profile did not start.`n", "*")
  ExitApp(1)
}

try Komorebi.startConfigAhk(A_ScriptDir "\fixtures\missing.ahk")
catch Error {
}
if (Komorebi.configAhkPid != firstPid or not ProcessExist(firstPid)) {
  FileAppend("A missing profile stopped the active profile.`n", "*")
  ExitApp(1)
}

Komorebi.startConfigAhk(profilePath)
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
