class NamedPipe
{
  ; Default open mode: read only.
  static DEFAULT_OPEN_MODE := 0x01
  ; Default pipe mode: type_message | readmode_message | nowait.
  static DEFAULT_PIPE_MODE := 0x04 | 0x02 | 0x01
  ; Default I/O buffer size: 64KB.
  static DEFAULT_BUFFER_SIZE := 64 * 1024

  __New(
    pipeName, ; Name of the pipe is mandatory.
    openMode := NamedPipe.DEFAULT_OPEN_MODE,
    pipeMode := NamedPipe.DEFAULT_PIPE_MODE,
    bufferSize := NamedPipe.DEFAULT_BUFFER_SIZE
  ) {
    this.pipeName := pipeName
    this.openMode := openMode
    this.pipeMode := pipeMode
    this.bufferSize := bufferSize
    this.pipeHandle := -1
  }

  isValid[pipe] => pipe >= 0
  lastErrorCode => A_LastError

  ; Create a named pipe object in the system with the specified parameters.
  ; The returned handle can be used for connecting, reading, and writing data.
  createNamedPipe() {
    try {
      pipePath := "\\.\pipe\" this.pipeName
      openMode := this.openMode
      pipeMode := this.pipeMode
      bufferSize := this.bufferSize

      ; https://learn.microsoft.com/en-us/windows/win32/ipc/named-pipe-operations
      pipeHandle := DllCall(
        "CreateNamedPipe",
        "Str", pipePath, ; Pipe path name
        "UInt", openMode, ; Open mode: access_inbound (read only)
        "UInt", pipeMode, ; Pipe modes: type_message | readmode_message | nowait
        "UInt", 1, ; Max number of instances
        "UInt", bufferSize, ; Output buffer size (in bytes)
        "UInt", bufferSize, ; Input buffer size (in bytes)
        "UInt", 0, ; Timeout in milliseconds
        "Ptr", 0, ; Security attributes (default)
        "Ptr" ; Return type: pointer (handle) to the loaded DLL
      )
      if (this.lastErrorCode != 0) {
        throw Error("Failed to create a named pipe.", this.lastErrorCode)
      }
    } catch Error as e {
      this.errorHandle(e.Message, this.lastErrorCode)
    }

    if (this.isValid[pipeHandle]) {
      return this.pipeHandle := pipeHandle
    }
  }

  ; Establish a connection to the named pipe using the instance handle.
  ; When a connection is established, the pipe can be used for data transfer.
  connectNamedPipe() {
    try {
      ; BUG: ConnectNamedPipe always returns zero.
      ; ERROR_PIPE_CONNECTED is returned on success. See: https://t.ly/G86aI
      DllCall("ConnectNamedPipe", "Ptr", this.pipeHandle, "Ptr", 0)
      if (this.lastErrorCode != 0) {
        throw Error("Failed connection to the named pipe.", this.lastErrorCode)
      }
    } catch Error as e {
      this.errorHandle(e.Message, this.lastErrorCode)
    }
  }

  ; Terminate active connections to the named pipe.
  ; Ensure that any active communication is ended.
  disconnectNamedPipe() {
    try {
      success := DllCall("DisconnectNamedPipe", "Ptr", this.pipeHandle)
      if (this.lastErrorCode != 0 and not success) {
        throw Error("Failed to disconnect the named pipe.", this.lastErrorCode)
      } else {
        OutputDebug("Success. Pipe " this.pipeHandle " disconnected.")
      }
    } catch Error as e {
      this.errorHandle(e.Message, this.lastErrorCode)
    }
  }

  ; Release system resources associated to the named pipe.
  ; Call after a proper disconnection to free system resources.
  closeHandle() {
    try {
      success := DllCall("CloseHandle", "Ptr", this.pipeHandle)
      if (this.lastErrorCode != 0 and not success) {
        throw Error("Failed to close connection to the named pipe.", this.lastErrorCode)
      } else {
        OutputDebug("Success. Handle " this.pipeHandle " is now closed.")
        this.pipeHandle := -1
        Sleep(200)
      }
    } catch Error as e {
      this.errorHandle(e.Message, this.lastErrorCode)
    }
  }

  ; Check the named pipe for available data.
  ; If valid data is obtained, return data as string.
  getData() {
    bytesToRead := 0
    bytesRead := 0
    bufferData := Buffer(this.bufferSize)

    success := DllCall(
      "PeekNamedPipe",
      "Ptr", this.pipeHandle, ; Handle to the named pipe instance.
      "Ptr", 0, ; Buffer that receives data read from the pipe.
      "UInt", 0, ; Size of the buffer for the read data (in bytes).
      "Ptr", 0, ; Variable that receives the number of bytes read.
      "PtrP", &bytesToRead, ; Bytes available to be read from the pipe.
      "Ptr", 0 ; Bytes remaining. Zero for byte-type named pipes or anonymous pipes.
    )
    if ( not success or not bytesToRead) {
      return false
    }
    success := DllCall(
      "ReadFile",
      "Ptr", this.pipeHandle, ; Handle to the named pipe instance.
      "Ptr", bufferData, ; Buffer that receives data read from the pipe.
      "UInt", this.bufferSize, ; Size of the buffer for the read data (in bytes).
      "UIntP", &bytesRead, ; Variable that receives the number of bytes read.
      "Ptr", 0 ; Overlapped flag (set to 0 for standard reading).
    )
    ; Re-check if less than 2 bytes (newlines)
    if ( not success or bytesRead <= 1) {
      return false
    }

    return StrGet(bufferData, bytesRead, "UTF-8")
  }

  ; System error codes:
  ; https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes--0-499-
  ; https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes--500-999-
  errorHandle(message, code) {
    switch code {
      case 6:
        code := "ERROR_INVALID_HANDLE"
        message := "The handle is invalid."
      case 231:
        code := "ERROR_PIPE_BUSY"
        message := "All pipe instances are busy."
      case 232:
        code := "ERROR_NO_DATA"
        message := "The pipe is being closed."
      case 535:
        code := "ERROR_PIPE_CONNECTED"
        message := "There is a process on other end of the pipe."
      case 536:
        code := "ERROR_PIPE_LISTENING"
        message := "Waiting for a process to open the other end of the pipe."
    }
    OutputDebug ("[" A_Now "] " String(code) ": " message)
  }
}
