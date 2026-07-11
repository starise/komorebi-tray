#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\lib\Komorebi.ahk
#Include ..\lib\NamedPipe.ahk

; Test komorebi pipe connection

PIPE_NAME := A_ScriptName
testPipe := NamedPipe(PIPE_NAME)

; Try to Connect to unexisting named pipe
; 6: ERROR_INVALID_HANDLE
testPipe.connect()

; Create a new named pipe
testPipe.create()

; The pipe is waiting for connection
; 536: ERROR_PIPE_LISTENING
testPipe.connect()

; Connect komorebi to the new pipe
Komorebi.subscribe(PIPE_NAME)

; The pipe is now connected
; 535: ERROR_PIPE_CONNECTED
testPipe.connect()

; Unsubscribe komorebi from the pipe
; Disconnect and close the handle
Komorebi.unsubscribe(PIPE_NAME)
testPipe.disconnect()
testPipe.closeHandle()

Sleep(500)

; Initialize a new pipe with a new handle
; Subscribe komorebi to the new pipe
testPipe.create()
Komorebi.subscribe(PIPE_NAME)

; Get some test events for the debugger
count := 0
pipeData := ""
lastData := ""
while (count < 5) {
  pipeData := testPipe.getData()
  if (pipeData and pipeData != lastData) {
    OutputDebug(pipeData)
    lastData := pipeData
    count++
  }
  Sleep(100)
}

; Disconnect and close the pipe handle
testPipe.disconnect()
testPipe.closeHandle()
