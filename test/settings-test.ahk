#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\lib\Settings.ahk

Settings.configFile := "test.ini"

Settings.save("default.ahk", "active", "profiles")

currentProfile := Settings.load("active", "profiles")

OutputDebug(Format("Current profile is: {}", currentProfile))

MsgBox(
  Format("Reading {1}: `n`n{2}",
    Settings.configFile,
    FileRead(Settings.configFile)
  )
)

Sleep(1000)

FileDelete Settings.configFile
