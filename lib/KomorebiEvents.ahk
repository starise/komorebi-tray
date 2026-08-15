#Include Komorebi.ahk
#Include KomorebiTray.ahk
#Include NamedPipe.ahk
#Include JSON.ahk

Class KomorebiEvents
{
  ; Name of the pipe.
  static pipeName := "komorebi-tray"
  ; Current named pipe instance.
  static pipe := NamedPipe(this.pipeName)
  ; Last valid event as json object.
  static lastEvent := ""
  ; Method for komorebi event listening.
  static listener := ObjBindMethod(this, "listen")
  ; Method to wait for komorebi to be launched.
  static waiter := ObjBindMethod(this, "wait")

  ; Start listening to komorebi named pipe.
  static start() {
    this.pipe.create()
    this.openConnection()
    SetTimer(this.listener, 10)
  }

  ; Stop listening and close the named pipe.
  static stop() {
    SetTimer(this.listener, 0)
    this.closeConnection()
  }

  ; Create and connect to a new named pipe.
  static openConnection() {
    Komorebi.subscribe(this.pipeName)
    this.pipe.connect()
  }

  ; Disconnect and close active named pipe.
  static closeConnection() {
    this.pipe.disconnect()
    this.pipe.closeHandle()
  }

  ; Wait for komorebi to exit the waiting state.
  static wait() {
    if (Komorebi.isRunning) {
      KomorebiEvents.start()
      KomorebiTray.start()
      SetTimer(this.waiter, 0)
    }
  }

  ; Listen to komorebi messages on the pipe.
  static listen() {
    ; Try to grab new event to evaluate
    event := this.pipe.getData()
    pipeError := this.pipe.lastErrorCode

    ; The connection has been lost, maybe komorebi has been stopped.
    ; Stop listening and wait for komorebi to be started.
    if (pipeError = this.pipe.ERROR_BROKEN_PIPE
      or pipeError = this.pipe.ERROR_BAD_PIPE) {
      KomorebiEvents.stop()
      KomorebiTray.waiting()
      if (pipeError = this.pipe.ERROR_BAD_PIPE and Komorebi.isRunning) {
        Komorebi.togglePause()
      }
      SetTimer(this.waiter, 2000)
      return
    }
    ; If the event is not empty and contains new data
    if (event and event != this.lastEvent) {
      try {
        state := JSON.Load(event)["state"]
        display := state["monitors"]["focused"] + 1
        displayData := state["monitors"]["elements"][display]
        workspace := displayData["workspaces"]["focused"] + 1
        workspaceData := displayData["workspaces"]["elements"][workspace]

        this.lastEvent := event
        Komorebi.isPaused := state["is_paused"]
        Komorebi.display := display
        Komorebi.displayName := displayData["name"]
        Komorebi.workspace := workspace
        workspaceName := workspaceData["name"]
        Komorebi.workspaceName := workspaceName
          ? workspaceName
          : "Workspace " workspace
      } catch Error as e {
        OutputDebug("Invalid komorebi event: " e.Message)
      }
    }
  }
}
