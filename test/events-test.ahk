#Requires AutoHotkey v2.0
#SingleInstance Force
#ErrorStdOut

#Include ..\lib\KomorebiEvents.ahk

class BadPipe
{
  ERROR_BROKEN_PIPE := 109
  ERROR_BAD_PIPE := 230
  lastErrorCode => this.ERROR_BAD_PIPE

  create() => 0
  connect() => 0
  disconnect() => 0
  closeHandle() => 0
  getData() => false
}

commandCalls := 0
waitingCalls := 0

notRunningStub(*) => false

togglePauseStub(*) {
  global commandCalls
  commandCalls++
}

subscribeStub(*) {
  global commandCalls
  commandCalls++
}

waitingStub(*) {
  global waitingCalls
  waitingCalls++
  KomorebiTray.currentIcon := "app"
}

Komorebi.DefineProp("isRunning", { Get: notRunningStub })
Komorebi.DefineProp("togglePause", { Call: togglePauseStub })
Komorebi.DefineProp("subscribe", { Call: subscribeStub })
KomorebiTray.DefineProp("waiting", { Call: waitingStub })
KomorebiEvents.pipe := BadPipe()
KomorebiTray.currentIcon := "d-1"

KomorebiEvents.listen()
SetTimer(KomorebiEvents.listener, 0)
SetTimer(KomorebiEvents.waiter, 0)

if (waitingCalls != 1
  or KomorebiTray.currentIcon != "app"
  or commandCalls) {
  FileAppend(
    "FAIL: waiting=" waitingCalls
    " icon=" KomorebiTray.currentIcon
    " commands=" commandCalls "`n",
    "*"
  )
  ExitApp(1)
}

FileAppend("PASS: bad pipe enters waiting state.`n", "*")
ExitApp(0)
