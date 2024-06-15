#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\lib\Popup.ahk

Popup.new("Message 1", 2000)

Sleep(500)

Popup.new("Message changed`nbefore timeout", 2000)

Sleep(2500)

Popup.new("Message after timeout", 2000)

Sleep(2000)

Popup.destroy()
