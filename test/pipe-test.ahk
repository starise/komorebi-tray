#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\lib\NamedPipe.ahk

; Test komorebi pipe connection

PIPE_NAME := A_ScriptName
testPipe := NamedPipe(PIPE_NAME)

; Try to Connect to unexisting named pipe
; 6: ERROR_INVALID_HANDLE
testPipe.connectNamedPipe()

; Create a new named pipe
testPipe.createNamedPipe()

; The pipe is waiting for connection
; 536: ERROR_PIPE_LISTENING
testPipe.connectNamedPipe()

; Connect komorebi to the new pipe
RunWait("komorebic.exe subscribe-pipe " PIPE_NAME, , "Hide")

; The pipe is now connected
; 535: ERROR_PIPE_CONNECTED
testPipe.connectNamedPipe()

; Unsubscribe komorebi from the pipe
; Disconnect and close the handle
RunWait("komorebic.exe unsubscribe-pipe " PIPE_NAME, , "Hide")
testPipe.disconnectNamedPipe()
testPipe.closeHandle()

Sleep(500)

; Initialize a new pipe with a new handle
; Subscribe komorebi to the new pipe
testPipe.createNamedPipe()
RunWait("komorebic.exe subscribe-pipe " PIPE_NAME, , "Hide")

; Get some test events for the debugger
count := 0
pipeData := ""
while (count < 5) {
  pipeData := testPipe.getData()
  if (pipeData) {
    OutputDebug(pipeData)
    count++
  }
}

; Disconnect and close the pipe handle
testPipe.disconnectNamedPipe()
testPipe.closeHandle()